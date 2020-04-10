require 'digest'
require 'typhoeus'
require 'uri'
require 'securerandom'

module LexisNexis
  module ThreatMetrix
    class VerificationRequest
      BASE_URL = 'https://h-api.online-metrix.net'.freeze

      attr_reader :attributes

      def initialize(attributes)
        @attributes = attributes
      end

      def send
        ThreatMetrix::Response.new(
          Typhoeus.post(url, body: body, headers: headers, timeout: timeout)
        )
      end

      def url
        URI.join(BASE_URL, '/api/session-query').to_s
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def body
        {
          api_key: api_key,
          org_id: org_id,
          service_type: 'session-policy',
          output_format: 'json',
          # Don't specify a policy, use the default one
          # policy: 'nao_s_bank',
          event_type: 'account_creation',
          session_id: SecureRandom.hex,
          transaction_id: '202003010', # TODO: random?

          # account_email: 'test@test.com',
          # input_ip_address: '255.255.255.0',

          account_login: attributes[:uuid],
          account_first_name: attributes[:first_name],
          account_last_name: attributes[:last_name],
          account_date_of_birth: date_of_birth,
          account_address_street1: attributes[:address1],
          account_address_street2: attributes[:address2] || '',
          account_address_city: attributes[:city],
          account_address_state: attributes[:state],
          account_address_zip: attributes[:zipcode],
          account_address_country: 'US',
          national_id_number: us_ssn_hash,
          national_id_type: 'US_SSN_HASH',
        }
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize

      def us_ssn_hash
        Digest::SHA256.hexdigest(attributes[:ssn].gsub(/\D/, ''))
      end

      def date_of_birth
        DateFormatter.new(attributes[:dob]).yyyymmdd
      end

      def timeout
        ENV.fetch('LEXISNEXIS_REQUEST_TIMEOUT', 5).to_i
      end

      def api_key
        ENV.fetch('lexisnexis_threat_metrix_api_key')
      end

      def org_id
        ENV.fetch('lexisnexis_threat_metrix_org_id')
      end

      def headers
        {
          'Accept' => 'application/json',
        }
      end
    end
  end
end
