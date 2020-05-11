module YetiException

  # Mixin for constructing and raising YetiException::Error or its subclasses.
  # It provides the 'raise_exception' method, which infers the class in which
  # the exception is raised so that it can be used in constructing the
  # exception.  This method is provided both on the class and on class
  # instances.
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

    # Define the class methods.
    # yardoc doesn't provide a way to ignore methods, so...

    # Metaprogramming - ignore
    def self.included(klass)
      klass.define_singleton_method(:raise_exception) do |exception_klass, details, *args|
        raise exception_klass.new(klass, details, *args)
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
  end
end
