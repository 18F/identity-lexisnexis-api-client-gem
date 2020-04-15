module LexisNexis
  module ThreatMetrix
    class ErrorParser
      attr_reader :body

      def initialize(body)
        @body = body
      end

      def parsed_errors
        { base: base_error_message }.merge(product_error_messages)
      end

      private

      def base_error_message
        error_code = body['summary_reason_code']
        return 'Verification failed without a reason code' if error_code.nil?
        "Verification failed with code: '#{error_code}'"
      end

      # Leaving blank now until we get a better sense of error reasons
      def product_error_messages
        {}
      end
    end
  end
end
