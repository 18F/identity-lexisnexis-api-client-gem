module LexisNexis
  module PhoneFinder
    class Proofer < LexisNexis::Proofer
      vendor_name 'lexisnexis:phone_finder'

      required_attributes :uuid,
                          :first_name,
                          :last_name,
                          :dob,
                          :ssn,
                          :phone

      stage :address

      proof do |applicant, result|
        proof_applicant(applicant, result)
      end

      def send_verification_request(applicant)
        VerificationRequest.new(applicant).send
      end
    end
  end
end
