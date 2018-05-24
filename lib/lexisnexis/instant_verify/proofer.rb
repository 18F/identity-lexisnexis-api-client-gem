module LexisNexis
  module InstantVerify
    class Proofer < LexisNexis::Proofer
      vendor_name 'lexisnexis:instant_verify'

      attributes :uuid,
                 :first_name,
                 :last_name,
                 :dob,
                 :ssn

      stage :resolution

      proof do |applicant, result|
        proof_applicant(applicant, result)
      end

      def send_verification_request(applicant)
        VerificationRequest.new(applicant).send
      end
    end
  end
end
