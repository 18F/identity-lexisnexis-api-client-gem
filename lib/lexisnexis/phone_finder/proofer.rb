module LexisNexis
  module PhoneFinder
    class Proofer < LexisNexis::Proofer
      attributes :uuid,
                 :first_name,
                 :last_name,
                 :dob,
                 :ssn,
                 :phone

      stage :address

      proof do |applicant, result|
        proof_applicant(applicant, result)
      end

      def send_verifcation_request(applicant)
        VerificationRequest.new(applicant).send
      end
    end
  end
end
