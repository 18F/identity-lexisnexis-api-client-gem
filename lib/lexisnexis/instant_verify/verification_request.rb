require 'date'
require 'json'
require 'securerandom'

module LexisNexis
  module InstantVerify
    class VerificationRequest < Request
      private

      def build_request_body # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
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
            DateOfBirth: date_of_birth,
            Addresses: [formatted_address],
          },
        }.to_json
      end

      def workflow_name
        ENV.fetch('lexisnexis_instant_verify_workflow')
      end

      def formatted_address
        {
          StreetAddress1: attributes[:address1],
          StreetAddress2: attributes[:address2] || '',
          City: attributes[:city],
          State: attributes[:state],
          Zip5: attributes[:zipcode].match(/^\d{5}/).to_s,
          Country: 'US',
          Context: 'primary',
        }
      end

      def date_of_birth
        formatter = DateFormatter.new(attributes[:dob])
        if attributes[:dob_year_only]
          if defined?(LoginGov::Hostdata) && LoginGov::Hostdata.env == 'staging' && defined?(Rails)
            Rails.logger.info("sending dob_year_only, uuid=#{uuid}")
          end
          formatter.formatted_year_only
        else
          formatter.formatted_date
        end
      end
    end
  end
end
