module LexisNexis
  class Proofer < Proofer::Base
    proof do |applicant, result|
      proof_applicant(applicant, result)
    end

    def proof_applicant(applicant, result)
      response = send_verifcation_request(applicant)
      return if response.verification_status == 'passed'
      raise response.transaction_error if response.verification_status == 'error'
      response.verification_errors.each do |key, error_message|
        result.add_error(key, error_message)
      end
    end

    private

    def send_verifcation_request
      raise NotImplementedError, "#{__method__} should be defined by a subclass"
    end
  end
end
