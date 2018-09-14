require 'json'

module LexisNexis
  class Response
    class UnexpectedHTTPStatusCodeError < StandardError; end
    class UnexpectedVerificationStatusCodeError < StandardError; end
    class VerificationTransactionError < StandardError; end

    attr_reader :response

    def initialize(response)
      @response = response
      handle_request_timeout_error
      handle_unexpected_http_status_code_error
      handle_unexpected_verification_status_error
      handle_verification_transaction_error
    end

    def verification_errors
      return {} unless verification_status == 'failed'
      VerificationErrorParser.new(response_body).parsed_errors
    end

    def verification_status
      @verification_status ||= response_body.dig('Status', 'TransactionStatus')
    end

    private

    def handle_request_timeout_error
      return unless response.timed_out?
      raise ::Proofer::TimeoutError, 'Timed out waiting for verification response'
    end

    def handle_unexpected_http_status_code_error
      return if response.success?
      message = "Unexpected status code '#{response.code}': #{response.body}"
      raise UnexpectedHTTPStatusCodeError, message
    end

    def handle_unexpected_verification_status_error
      return if %w[passed failed error].include?(verification_status)
      message = "Invalid status in response body: '#{verification_status}'"
      raise UnexpectedVerificationStatusCodeError, message
    end

    def handle_verification_transaction_error
      return unless verification_status == 'error'
      error_code = response_body.dig('Status', 'TransactionReasonCode', 'Code')
      error_information = response_body.fetch('Information', {}).to_json
      message = "Response error with code '#{error_code}': #{error_information}"
      raise VerificationTransactionError, message
    end

    def response_body
      @response_body ||= JSON.parse(response.body)
    end
  end
end
