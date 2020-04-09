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
        REVIEW_STATUS_MAP.fetch(response_body['review_status'])
      end
    end
  end
end
