module LexisNexis
  module ThreatMetrix
    class Response
      attr_reader :response

      def initialize(response)
        @response = response
      end

      def verification_errors
      end

      def verification_status
      end
    end
  end
end
