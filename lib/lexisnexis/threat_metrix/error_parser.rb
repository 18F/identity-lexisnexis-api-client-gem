module LexisNexis
  module ThreatMetrix
    class ErrorParser
      attr_reader :body

      def initialize(body)
        @body = body
      end

      def parsed_errors
        { base: base_error_message }.merge(product_error_messages)
      end

      private

      def base_error_message
        # error_code = body.dig('Status', 'TransactionReasonCode', 'Code')
        # return 'Verification failed without a reason code' if error_code.nil?
        # "Verification failed with code: '#{error_code}'"
      end

      def product_error_messages
        {}
        # products = body['Products']
        # return { products: 'Products missing from response' } if products.nil?
        # products.each_with_object({}) do |product, error_messages|
        #   next if product['ProductStatus'] == 'pass'
        #   key = product.fetch('ExecutedStepName').to_sym
        #   error_messages[key] = product.to_json
        # end
      end
    end
  end
end