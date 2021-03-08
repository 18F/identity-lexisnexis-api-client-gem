require 'base64'
require 'uri'
require 'faraday'
require 'active_support/core_ext/object/blank'

module LexisNexis
  class RequestError < StandardError; end

  class Request
    attr_reader :config, :applicant, :url, :headers, :body

    def initialize(config:, applicant:)
      @config = config
      @applicant = applicant
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
        f.basic_auth config.username, config.password
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
      config.account_id
    end

    def base_url
      config.base_url
    end

    def build_request_headers
      {
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

    def mode
      config.request_mode
    end

    def url_request_path
      "/restws/identity/v2/#{account_number}/#{workflow_name}/conversation"
    end

    def uuid
      uuid = applicant.fetch(:uuid, SecureRandom.uuid)
      uuid_prefix = applicant[:uuid_prefix]

      if uuid_prefix.present?
        "#{uuid_prefix}:#{uuid}"
      else
        uuid
      end
    end

    def timeout
      (config.request_timeout || 5).to_i
    end
  end
end
