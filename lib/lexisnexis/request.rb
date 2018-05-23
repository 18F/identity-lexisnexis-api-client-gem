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
        Typhoeus.post(url, body: body, headers: headers)
      )
    end

    private

    def account_number
      ENV.fetch('LEXISNEXIS_ACCOUNT_ID')
    end

    def base_url
      ENV.fetch('LEXISNEXIS_BASE_URL')
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
        "#{ENV.fetch('LEXISNEXIS_USERNAME')}:#{ENV.fetch('LEXISNEXIS_PASSWORD')}"
      )
    end

    def mode
      ENV.fetch('LEXISNEXIS_REQUEST_MODE')
    end

    def url_request_path
      "/restws/identity/v2/#{account_number}/#{workflow_name}/conversation"
    end

    def uuid
      attributes.fetch(:uuid, SecureRandom.uuid)
    end
  end
end
