require 'base64'
require 'uri'
require 'faraday'
require 'active_support/core_ext/object/blank'

module LexisNexis
  class RequestError < StandardError; end

  class Request
    attr_reader :attributes, :url, :headers, :body

    def initialize(attributes)
      @attributes = attributes
      @body = build_request_body
      @headers = build_request_headers
      @url = build_request_url
    end

    # @see Response#initialize
    # @param [Hash<Symbol, Object>] response_options a hash of options for the Response class
    #   * +:dob_year_only+
    def send(response_options: {})
      conn = Faraday.new do |f|
        f.options[:timeout] = timeout
      end

      Response.new(
        conn.post(url, body, headers), **response_options
      )
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed => e
      # NOTE: This is only for when Faraday is using NET::HTTP if the adapter is changed
      # this will have to change to handle timeouts
      if e.message == 'execution expired'
        raise ::Proofer::TimeoutError,
              'LexisNexis timed out waiting for verification response'
      else
        message = "Lexis Nexis request raised #{e.class} with the message: #{e.message}"
        raise LexisNexis::RequestError, message
      end
    end

    private

    def account_number
      ENV.fetch('lexisnexis_account_id')
    end

    def base_url
      ENV.fetch('lexisnexis_base_url')
    end

    def build_request_headers
      {
        'Authorization' => "Basic #{encoded_credentials}",
        'Content-Type' => 'application/json',
      }
    end

    def build_request_body
      raise NotImplementedError, "#{__method__} should be defined by a subclass"
    end

    def build_request_url
      URI.join(
        base_url,
        url_request_path
      ).to_s
    end

    def encoded_credentials
      Base64.strict_encode64(
        "#{ENV.fetch('lexisnexis_username')}:#{ENV.fetch('lexisnexis_password')}"
      )
    end

    def mode
      ENV.fetch('lexisnexis_request_mode')
    end

    def url_request_path
      "/restws/identity/v2/#{account_number}/#{workflow_name}/conversation"
    end

    def uuid
      uuid = attributes.fetch(:uuid, SecureRandom.uuid)
      uuid_prefix = attributes[:uuid_prefix]

      if uuid_prefix.present?
        "#{uuid_prefix}:#{uuid}"
      else
        uuid
      end
    end

    def timeout
      ENV.fetch('LEXISNEXIS_REQUEST_TIMEOUT', 5).to_i
    end
  end
end
