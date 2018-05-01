module LexisNexis
  class VerificationErrorParser
    attr_reader :body

    def initialize(response_body)
      @body = response_body
    end

    def parsed_errors
      { base: base_error_message }.merge(product_error_messages)
    end

    private

    def base_error_message
      error_code = body.dig('Status', 'TransactionReasonCode', 'Code')
      return 'Verification failed without a reason code' if error_code.nil?
      "Verification failed with code: '#{error_code}'"
    end

    def product_error_messages
      products = body['Products']
      return { products: 'Products missing from response' } if products.nil?
      error_messages = {}
      products.each do |product|
        next if product['ProductStatus'] == 'pass'
        key = product.fetch('ExecutedStepName').to_sym
        error_messages[key] = product.to_json
      end
      error_messages
    end
  end
end
