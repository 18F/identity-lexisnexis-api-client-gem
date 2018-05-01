module LexisNexis
  module PhoneFinder
    class VerificationRequest < Request
      private

      def build_request_body # rubocop:disable Metrics/MethodLength
        {
          Settings: {
            Workflow: 'PhoneFinder_WF',
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
            Phones: [
              {
                Number: attributes[:phone],
              },
            ],
          },
        }.to_json
      end

      def url_request_path
        "/restws/identity/v2/#{ENV.fetch('LEXISNEXIS_ACCOUNT_ID')}/PhoneFinder/conversation"
      end
    end
  end
end
