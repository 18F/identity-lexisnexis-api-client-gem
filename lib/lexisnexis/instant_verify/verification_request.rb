require 'date'
require 'json'
require 'securerandom'

module LexisNexis
  module InstantVerify
    class VerificationRequest < Request
      private

      def build_request_body # rubocop:disable Metrics/MethodLength
        {
          Settings: {
            Workflow: 'BK_IDM_WF',
            Mode: mode,
            Reference: uuid,
          },
          Person: {
            Name: {
              FirstName: attributes[:first_name],
              LastName: attributes[:last_name],
            },
            SSN: {
              Number: attributes[:ssn],
              Type: 'ssn9',
            },
            DateOfBirth: DateFormatter.new(attributes[:dob]).formatted_date,
          },
        }.to_json
      end

      def url_request_path
        "/restws/identity/v2/#{ENV.fetch('LEXISNEXIS_ACCOUNT_ID')}/InstantVerify/conversation"
      end
    end
  end
end
