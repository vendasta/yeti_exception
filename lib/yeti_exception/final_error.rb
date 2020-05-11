module YetiException

  # A final, i.e. non-transient error that should not be retried

  class FinalError < Error

    # @param klass [Class] Class in which the exception occurred
    # @param details [Hash] Arbitrary details about the exception
    # @param http_status [Integer] Corresponding HTTP status
    def initialize(klass, details, http_status = 500)
      super(klass, details, false, http_status)
    end

  end
end
