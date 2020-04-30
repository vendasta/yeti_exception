# yeti_exception

Enhanced exceptions with a details hash and more

## Installation

Add this line to your application's Gemfile:

    gem 'yeti_exception'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install yeti_exception

## Usage

### The `YetiException::Error` class

`YetiException::Error` is a subclass of `StandardError` that adds some extra
attributes:

- The class in which the exception was raised

- A `Hash` of arbitrary details about the exception

- A `transient` boolean flag

- An HTTP response status

The exception's `#message` is constructed as a string of `key=value` pairs from
the details hash.

    ex = YetiException::Error.new(self,                                 # class
                                  { some: 'details', more: 'stuff' },   # details hash
                                  false,                                # transient
                                  400)                                  # HTTP status

    ex.message #=> "some=\"details\" more=\"stuff\""

Default values for `transient` and `http_status` will be used if not provided.

    ex = YetiException::Error.new(self, { some: 'details', more: 'stuff' })

    ex.transient #=> true
    ex.http_status #=> 500

### Subclasses and customization

`YetiException::Error` has some simple included subclasses for convenience.

`YetiException::FinalError` is a non-transient error.  Its default HTTP status
is 500.

    ex = YetiException::FinalError.new(self, { some: 'details', more: 'stuff' }, 503)

    ex.transient #=> false

    ex = YetiException::FinalError.new(self, { some: 'details', more: 'stuff' })

    ex.http_status #=> 500

`YetiException::ClientError` is similar.  It is intended to represent an invalid
HTTP request, so its default HTTP status is 400.

    ex = YetiException::ClientError.new(self, { some: 'details', more: 'stuff' }, 404)

    ex.transient #=> false

    ex = YetiException::ClientError.new(self, { some: 'details', more: 'stuff' })

    ex.http_status #=> 400

Custom subclasses can be useful if you want to handle specific exceptions
differently.

    class MySpecialError < YetiException::Error; end

    begin
      do_something
    rescue MySpecialError => ex
      puts "Special: #{ex.message}"
    rescue => ex
      puts "Not so special: #{ex.message}"
    end

Custom subclasses can also define a static message that will be merged into the
exception's details hash automatically.

    class MySpecialError < YetiException::Error
      def msg
        'Something special'
      end
    end

    ex = MySpecialError.new(self, { some: 'details' })

    ex.details #=> {:msg=>"Something special", :some=>"details"} 

The static message will not overwrite a `:msg` key included explicitly in the details.

    class MySpecialError < YetiException::Error
      def msg
        'Something special'
      end
    end

    ex = MySpecialError.new(self, { some: 'details', msg: 'Even more special' })

    ex.details #=> {:msg=>"Even more special", :some=>"details"}

### The `YetiException::Helpers` mixin

`YetiException::Helpers` is a mixin that provides two convenience methods.  Each
is defined as both a class and instance method.

The first is `raise_exception`.  `YetiException::Error` has a `klass` attribute
containing the class in which the exception was raised so that it may be used in
log searching.  While the raising class can be inferred from the exception's
backtrace, the class name is more intuitive.  `raise_exception` removes the need
to reference the class explicitly.

    class MyClass
      include YetiException::Helpers

      def call
        raise_exception(YetiException::Error, { some: 'details' })
      end
    end

    ex = begin
      MyClass.new.call
    rescue => exception
      exception
    end

    ex.klass #=> MyClass

Any `YetiException::Error` subclass can be raised, and additional parameters are
passed to the exception's `#initialize` method:

    raise_exception(MyCustomError,             # exception class
                    { some: 'details' },       # details
                    false,                     # transient
                    400)                       # HTTP status

The second convenience method is `wrap_exception` This is used to wrap arbitrary
exceptions in a `YetiException::Error` and re-raise the new exception.  It adds
the same attributes as `raise_exception`, but also does the following:

- It maintains the original exception's backtrace.  This useful for identifying
  where the exception was originally raised, not where it was wrapped and
  reraised.

- It includes the original exception's message in the `:msg` key of the details
  hash.

Note that this example uses the class method instead of the instance method to
demonstrate both cases.

    class OtherClass
      ORIGINAL_ERROR = StandardError.new('Original error')

      def self.call
        raise ORIGINAL_ERROR
      end
    end

    class MyClass
      include YetiException::Helpers

      def self.call
        OtherClass.call
      rescue => ex
        wrap_exception(ex, YetiException::Error, { some: 'details' })
      end
    end

    ex = begin
      MyClass.call
    rescue => exception
      exception
    end

    ex.klass #=> MyClass
    ex.details #=> {:some=>"details", :msg=>"Original error"}
    ex.backtrace == OtherClass::ORIGINAL_ERROR.backtrace #=> true

Again, a custom subclass and additional parameter can be used:

    wrap_exception(ex,                        # original exception
                   MyCustomError,             # exception class
                   { some: 'details' },       # details
                   false,                     # transient
                   400)                       # HTTP status

### Integration with [YetiLogger](https://github.com/Yesware/yeti_logger)

`YetiException` was designed with `YetiLogger` in mind.  `YetiLogger`
automatically handles logging a details hash with an optional exception.

    begin
      do_something
    rescue YetiException::Error => ex
      log_error(ex.details, ex)
    end

The class in which the exception was raised can also be included.

    begin
      do_something
    rescue YetiException::Error => ex
      log_error(ex.details.merge(klass: ex.klass), ex)
    end

### Integration with Ruby on Rails controllers

The `http_status` attribute of `YetiException::Error` can be used when rescuing
an exception in a Rails controller.  If your application uses `YetiException`
for all errors, it makes sense to define a `rescue_from` hander in
`ApplicationController`.  For example, for an API-only app:

    class ApplicationController < ActionController::API

      # Define a catch-all handler for other exceptions.  Rails searches for a
      # matching handler in the reverse order of their definitions.
      rescue_from StandardError do |ex|
        render json: { error: ex.message }, status: 500
      end

      # For the YetiException exceptions with richer data, use the specified
      # details and status.
      rescue_from YetiException::Error do |ex|
        render json: { error: ex.details }, status: ex.status
      end
    end

### Integration with asynchronous job frameworks

For asynchronous job frameworks like [Sidekiq](https://sidekiq.org) or
[Sneakers](http://jondot.github.io/sneakers/), exceptions can be caught in the
worker entry point, and the `transient` attribute can be used to retry the job
or fail it outright.

A framework-agnostic example:

    class MyWorker
      def entry_point
        do_something
      rescue YetiException::Error => ex
        if ex.transient

          # retry the job

        else

          # fail the job

        end
      end
    end

## Contributing

1. Fork it ( https://github.com/Yesware/yeti_exception/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
