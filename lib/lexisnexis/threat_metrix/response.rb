module LexisNexis
  module ThreatMetrix
    class Response < ::LexisNexis::Response
      # Maps from ThreatMetrix review_status to match InstantVerify statuses so
      # we can match the interface Proofer expects
      REVIEW_STATUS_MAP = {
        'pass' => 'passed',
        'reject' => 'failed',
        'review' => 'failed',
      }.freeze

      def verification_errors
        return {} unless verification_status == 'failed'

        ::LexisNexis::ThreatMetrix::ErrorParser.new(response_body).parsed_errors
      end

      def verification_status
        raw_review_status = response_body['review_status']
        REVIEW_STATUS_MAP.fetch(raw_review_status, raw_review_status)
      end

      def handle_verification_transaction_error
        request_result = response_body['request_result']
        return if request_result == 'success'

        message = "Invalid request_result in response body: '#{verification_status}'"
        raise UnexpectedVerificationStatusCodeError, message
      end
    end
  end
end
