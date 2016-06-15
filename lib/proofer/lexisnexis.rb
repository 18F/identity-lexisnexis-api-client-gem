require 'proofer/vendor/vendor_base'
require 'lexis_nexis_instant_authenticate'
require 'lexisnexis/applicant'

module Proofer
  module Vendor
    class Lexisnexis < VendorBase
      def coerce_vendor_applicant(ln_applicant)
        Proofer::Applicant.new(
          first_name: ln_applicant.first_name,
          middle_name: ln_applicant.middle_name,
          last_name: ln_applicant.last_name,
          ssn: ln_applicant.ssn,
          dob: [ln_applicant.dob[:year], ln_applicant.dob[:month], ln_applicant.dob[:day]].join(''),
          phone: ln_applicant.phone,
          address1: ln_applicant.address[:line_1],
          address2: ln_applicant.address[:line_2],
          city: ln_applicant.address[:city],
          state: ln_applicant.address[:state],
          zipcode: ln_applicant.address[:zip_code]
        )
      end

      def perform_resolution
        ln_applicant = LexisNexis::Applicant.from_proofer_applicant(applicant)

        resp = client.create_quiz(ln_applicant)

        if resp.success?
          successful_resolution(resp)
        else
          failed_resolution(resp)
        end
      end

      def submit_answers(question_set, session_id)

      end

      private

      def client
        @_client ||= LexisNexisInstantAuthenticate::Client.new
          username: ENV['LEXISNEXIS_USERNAME'],
          password: ENV['LEXISNEXIS_PASSWORD'],
          flow: (ENV['LEXISNEXIS_FLOW'] || 'VERIFY_AUTH_COMBO')
        )
      end

      def successful_resolution(resp)
        Proofer::Resolution.new(
          success: true,
          vendor_resp: resp,
          questions: build_questions(resp.questions),
          session_id: resp.transaction_id
        )
      end

      def failed_resolution(resp)
        Proofer::Resolution.new(
          success: false,
          vendor_resp: resp,
          session_id: resp.transaction_id
        )
      end
    end
  end
end
