module LexisNexis
  module PhoneFinder
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

      def workflow_name
        ENV.fetch('lexisnexis_phone_finder_workflow')
      end
    end
  end
end
