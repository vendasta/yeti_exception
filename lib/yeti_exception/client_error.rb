module YetiException

  # An error caused by an invalid HTTP request from a client.  This is not a
  # transient error and so will not succeed on retry.

  class ClientError < Error

    # @param klass [Class] Class in which the exception occurred
    # @param details [Hash] Arbitrary details about the exception
    # @param http_status [Integer] Corresponding HTTP status
    def initialize(klass, details, http_status = 400)
      super(klass, details, false, http_status)
    end

  end
end
