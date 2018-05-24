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
            AccountNumber: account_number,
            Mode: mode,
            Reference: uuid,
            Locale: 'en_US',
            Venue: 'online',
          },
          Person: {
            Name: {
              FirstName: attributes[:first_name],
              LastName: attributes[:last_name],
            },
            SSN: {
              Number: attributes[:ssn].gsub(/\D/, ''),
              Type: 'ssn9',
            },
            DateOfBirth: DateFormatter.new(attributes[:dob]).formatted_date,
          },
        }.to_json
      end

      def workflow_name
        ENV.fetch('lexisnexis_instant_verify_workflow')
      end
    end
  end
end
