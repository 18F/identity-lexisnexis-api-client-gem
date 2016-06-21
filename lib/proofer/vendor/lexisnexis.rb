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
          dob: [ln_applicant.dob.year, ln_applicant.dob.month, ln_applicant.dob.day].join(''),
          phone: ln_applicant.phone,
          address1: ln_applicant.address.line_1,
          address2: ln_applicant.address.line_2,
          city: ln_applicant.address.city,
          state: ln_applicant.address.state,
          zipcode: ln_applicant.address.zip_code
        )
      end

      def verify_flow
        ENV['LEXISNEXIS_VERF_FLOW']
      end

      def auth_flow
        ENV['LEXISNEXIS_AUTH_FLOW']
      end

      def perform_resolution
        ln_applicant = LexisNexis::Applicant.from_proofer_applicant(applicant).to_hash(symbolize_keys: true)
        verify_resp = client(flow: verify_flow).create_quiz(ln_applicant)

        if verify_flow_success?(verify_resp)
          exam_resp = client(flow: auth_flow).create_quiz(ln_applicant)
          if exam_resp.success? && vendor_resp_has_exam?(exam_resp)
            successful_resolution(exam_resp.proofing_response, exam_resp.transaction_id)
          else
            failed_resolution(exam_resp.proofing_response, exam_resp.transaction_id)
          end
        else
          failed_resolution(verify_resp.proofing_response, verify_resp.transaction_id)
        end
      end

      def submit_answers(question_set, session_id)
        answers = question_set.map do |question|
          { question_id: question.key, choice_id: key_for_choice(question) }
        end
        score_resp = client(flow: auth_flow, transaction_id: session_id).score_quiz(question_set.id, answers)
        if score_resp.pass?
          successful_confirmation(score_resp)
        else
          failed_confirmation(score_resp)
        end
      end

      def key_for_choice(question)
        question.choices.select do |choice|
          choice.key == question.answer || choice.display == question.answer
        end.first.key
      end
      private :key_for_choice

      def build_question_set(resp)
        questions = resp[:product_response][:questions][:question].map do |question|
          choices = question[:choice].map do |choice|
            Proofer::QuestionChoice.new(
              key: choice[:'@ns:choice_id'],
              display: choice[:text]
            )
          end
          Proofer::Question.new(
            key: question[:'@ns:question_id'],
            display: question[:text],
            choices: choices
          )
        end
        Proofer::QuestionSet.new(questions, resp[:product_response][:questions][:"@ns:quiz_id"])
      end

      def client(opts)
        LexisNexisInstantAuthenticate::Client.new(
          username: ENV['LEXISNEXIS_USERNAME'],
          password: ENV['LEXISNEXIS_PASSWORD'],
          log_level: (ENV['LEXISNEXIS_DEBUG'] ? :debug : :warn),
          flow: opts[:flow],
          transaction_id: (opts[:transaction_id] || SecureRandom.uuid)
        )
      end
      private :client

      def verify_threshold
        ENV['LEXISNEXIS_VERIFY_THRESHOLD'] || options[:verify_threshold]
      end
      private :verify_threshold

      def verify_flow_success?(resp)
        if verify_threshold
          meets_verify_threshold?(resp)
        else
          resp.status != 'FAIL'
        end
      end
      private :verify_flow_success?

      def meets_verify_threshold?(resp)
        n_passes = 0
        n_checks = 0
        resp.product_response[:verification_sub_product_response][:check_group].each do |check|
          if check[:check].is_a?(Array)
            check[:check].each do |subcheck|
              n_checks += 1
              if subcheck[:status] == 'PASS'
                n_passes += 1
              end
            end
          else
            n_checks += 1
            if check[:check][:status] == 'PASS'
              n_passes += 1
            end
          end
        end
        n_checks.fdiv(n_passes) >= verify_threshold.to_f
      end
      private :meets_verify_threshold?

      def vendor_resp_has_exam?(resp)
        if resp.status == 'FAIL'
          false
        elsif resp.questions
          true
        end
      end
      private :vendor_resp_has_exam?
    end
  end
end
