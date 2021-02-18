module LexisNexis
  class VerificationErrorParser
    attr_reader :body

    def initialize(response_body, dob_year_only: false)
      @body = response_body
      @dob_year_only = dob_year_only
    end

    def dob_year_only?
      @dob_year_only
    end

    def parsed_errors
      { base: base_error_message }.merge(product_error_messages)
    end

    def verification_status
      @verification_status ||= begin
        status = body.dig('Status', 'TransactionStatus')

        if status == 'failed' && dob_year_only? && product_error_messages.empty?
          'passed'
        else
          status
        end
      end
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

        if dob_year_only? && product['ProductType'] == 'InstantVerify'
          next if instant_verify_dob_year_only_pass?(product['Items'])
        end

        key = product.fetch('ExecutedStepName').to_sym
        error_messages[key] = product.to_json
      end
    end

    # if DOBYearVerified passes, but DOBFullVerified fails, we can still allow a pass
    # @return [Boolean]
    def instant_verify_dob_year_only_pass?(items)
      dob_year_verified = items.find { |item| item['ItemName'] == 'DOBYearVerified' }
      # in this limited case, we essentially ignore this item
      _dob_full_verified = items.find { |item| item['ItemName'] == 'DOBFullVerified' }
      other_checks = items.reject { |item| %w[DOBYearVerified DOBFullVerified].include?(item['ItemName']) }

      item_passed?(dob_year_verified) && other_checks.all? { |item| item_passed?(item) }
    end

    def item_passed?(item)
      item && item['ItemStatus'] == 'pass'
    end
  end
end
