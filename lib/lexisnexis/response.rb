require 'json'

module LexisNexis
  class Response
    class ResponseError < StandardError; end

    attr_reader :body

    def initialize(response_body)
      @body = JSON.parse(response_body)
    end

    def transaction_error
      return unless verification_status == 'error'
      error_code = body.dig('Status', 'TransactionReasonCode', 'Code')
      error_information = body.fetch('Information', {}).to_json
      ResponseError.new("Response error with code '#{error_code}': #{error_information}")
    end

    def verification_errors
      return {} unless verification_status == 'failed'
      VerificationErrorParser.new(body).parsed_errors
    end

    def verification_status
      @verification_status ||= begin
        status = body.dig('Status', 'TransactionStatus')
        handle_unexpected_status_error(status)
        status
      end
    end

    private

    def handle_unexpected_status_error(status)
      return if %w[passed failed error].include?(status)
      raise ResponseError, "Invalid status in response body: '#{status}'"
    end
  end
end
