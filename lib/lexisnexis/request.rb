require 'base64'
require 'typhoeus'
require 'uri'

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

    def send
      Response.new(
        Typhoeus.post(url, body: body, headers: headers, timeout: timeout)
      )
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
      attributes.fetch(:uuid, SecureRandom.uuid)
    end

    def timeout
      ENV.fetch('LEXISNEXIS_REQUEST_TIMEOUT', 5).to_i
    end
  end
end
