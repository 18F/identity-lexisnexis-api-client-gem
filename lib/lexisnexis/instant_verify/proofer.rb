module LexisNexis
  module InstantVerify
    class Proofer < LexisNexis::Proofer
      attributes :uuid,
                 :first_name,
                 :last_name,
                 :dob,
                 :ssn

      stage :resolution

      proof do |applicant, result|
        proof_applicant(applicant, result)
      end

      def send_verifcation_request(applicant)
        VerificationRequest.new(applicant).send
      end
    end
  end
end
