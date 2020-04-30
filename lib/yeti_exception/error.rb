require 'json'

module YetiException

  # Enhanced exception class, with some features added beyond those in
  # StandardError:
  #
  # - The class in which the exception was raised.  This can be useful for
  #   logging, since the backtrace is much more verbose.
  #
  # - A details hash, containing arbitrary key/value pairs related to the
  #   exception.
  #
  # - A transient flag, defaulting to true, indicating whether the exception
  #   should be considered transient or final.  This can be used when rescuing
  #   the exception to determine whether the operation should be retried.
  #
  # - An HTTP status, defaulting to 500.  This can be used to generate the
  #   response payload if the exception is rescued as part of an HTTP request.
  #
  # - An optional static message, definable by subclasses, to be included
  #   automatically in the details hash.  This removes the need to pass this
  #   message in explicitly during initialization.

  class Error < StandardError

    # @return [Class] Class in which the exception occurred
    attr_reader :klass
    # @return [Hash] Arbitrary details about the exception
    attr_reader :details
    # @return [TrueClass, FalseClass] Whether the error is transient,
    #   i.e. possible to succeed if retried in the future
    attr_reader :transient
    # @return [Integer] Corresponding HTTP status
    attr_reader :http_status

    # @param klass [Class] Class in which the exception occurred
    # @param details [Hash] Arbitrary details about the exception
    # @param transient [TrueClass, FalseClass] Whether the error is transient
    # @param http_status [Integer] Corresponding HTTP status
    def initialize(klass, details, transient = true, http_status = 500)
      @klass = klass
      # Merge in default message if defined, but don't overwrite a message
      # provided in the details.
      @details = msg.nil? ? details : { msg: msg }.merge(details)
      @transient = transient
      @http_status = http_status
      # Build a "key=value" string from the details hash to use as the
      # exception's message
      super(details.map { |k, v| "#{k}=#{v.to_json}" }.join(' '))
    end

    # Optional message that will be merged into the details hash.
    # Can be implemented by subclass.
    #
    # @return [String, NilClass]
    def msg
      nil
    end
  end
end
