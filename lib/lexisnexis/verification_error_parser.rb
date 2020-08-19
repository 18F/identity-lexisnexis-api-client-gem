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
      conversation_id = body.dig('Status', 'ConversationId')
      reference = body.dig('Status', 'Reference')
      tracking_ids = "(LN ConversationId: #{conversation_id}; Reference: #{reference}) "

      return "#{tracking_ids} Verification failed without a reason code" if error_code.nil?

      "#{tracking_ids} Verification failed with code: '#{error_code}'"
    end

    def product_error_messages
      products = body['Products']
      return { products: 'Products missing from response' } if products.nil?

      products.each_with_object({}) do |product, error_messages|
        next if product['ProductStatus'] == 'pass'

        key = product.fetch('ExecutedStepName').to_sym
        error_messages[key] = product.to_json
      end
    end
  end
end
