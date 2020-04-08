module LexisNexis
  # Verifies through the DDP platform (newer)
  class ThreatMetrix
    class Proofer < LexisNexis::Proofer
      vendor_name 'lexisnexis:threat_metrix_ddp'

      required_attributes :uuid,
                          :first_name,
                          :last_name,
                          :dob,
                          :ssn,
                          :address1,
                          :city,
                          :state,
                          :zipcode

      optional_attributes :address2

      stage :resolution

      proof do |applicant, result|
        proof_applicant(applicant, result)
      end

      def send_verification_request(applicant)
        VerificationRequestDdp.new(applicant).send
      end
    end
  end
end