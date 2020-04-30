module YetiException

  # Mixin for constructing and raising YetiException::Error or its subclasses.
  # Two convenience methods are provided, both on the class and on class
  # instances:
  #
  # - raise_exception: Infers the class in which the exception is raised so that
  #   it can be used in constructing the exception.
  #
  # - wrap_exception: Creates a new YetiException exception from an arbitrary
  #   exception, maintaining the orignal's backtrace.  This is useful when
  #   dealing with exceptions from third-party code, so that the extra features
  #   of YetiException may be used without losing the location of the original
  #   error.
  #
  # Example usage:
  #
  #     class MyClass
  #       include YetiException::Helpers
  #
  #       def foo(x)
  #         if x.nil?
  #           raise_exception(YetiException::Error,
  #                           {
  #                             msg: 'x is nil',
  #                             something: 'interesting'
  #                           })
  #         end
  #       end
  #
  #       def bar(y)
  #         ThirdParty.Bar(y)
  #       rescue => ex
  #         wrap_exception(ex,
  #                        YetiException::Error,
  #                        {
  #                          y_value: y
  #                        })
  #       end
  #     end

  module Helpers

    # Raise the specified exception, inferring the calling class automatically.
    #
    # @param exception_klass [Class]
    # @param details [Hash]
    # @param args [Object ...]
    # @raise [YetiException::Error]
    def raise_exception(exception_klass, details, *args)
      raise exception_klass.new(self.class, details, *args)
    end

    # Wrap an arbitrary exception in a new enhanced exception and reraise,
    # preserving the original backtrace and merging the original message into
    # the details.
    #
    # @param original_exception [Exception]
    # @param new_exception_klass [Class]
    # @param details [Hash]
    # @param args [Object ...]
    # @raise [YetiException::Error]
    def wrap_exception(original_exception, new_exception_klass, details, *args)
      new_details = details.merge(msg: original_exception.message)
      new_exception = new_exception_klass.new(self.class, new_details, *args).tap do |ex|
        ex.set_backtrace(original_exception.backtrace)
      end
      raise new_exception
    end

    # Define the class methods.
    # yardoc doesn't provide a way to ignore methods, so...

    # Metaprogramming - ignore
    def self.included(klass)
      klass.define_singleton_method(:raise_exception) do |exception_klass, details, *args|
        raise exception_klass.new(klass, details, *args)
      end

      klass.define_singleton_method(:wrap_exception) do |original_exception, new_exception_klass, details, *args|
        new_details = details.merge(msg: original_exception.message)
        new_exception = new_exception_klass.new(klass, new_details, *args).tap do |ex|
          ex.set_backtrace(original_exception.backtrace)
        end
        raise new_exception
      end
    end

    # yardoc for metaprogrammed class methods
    # See https://github.com/lsegal/yard/issues/1208

    # @!method raise_exception(exception_klass, details, *args)
    # @!scope class
    # Raise the specified exception, inferring the calling class automatically.
    #
    # @param exception_klass [Class]
    # @param details [Hash]
    # @param args [Object ...]
    # @raise [YetiException::Error]

    # @!method wrap_exception(original_exception, new_exception_klass, details, *args)
    # @!scope class
    # Wrap an arbitrary exception in a new enhanced exception and reraise,
    # preserving the original backtrace and merging the original message into
    # the details.
    #
    # @param original_exception [Exception]
    # @param new_exception_klass [Class]
    # @param details [Hash]
    # @param args [Object ...]
    # @raise [YetiException::Error]
  end
end
