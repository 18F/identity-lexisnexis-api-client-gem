module LexisNexis
  class Proofer < Proofer::Base
    def proof_applicant(applicant, result)
      response = send_verification_request(applicant)
      return if response.verification_status == 'passed'

      response.verification_errors.each do |key, error_message|
        result.add_error(key, error_message)
      end
    end

    private

    def send_verification_request
      raise NotImplementedError, "#{__method__} should be defined by a subclass"
    end
  end
end
