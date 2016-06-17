require 'spec_helper'

require 'proofer'

describe 'Proofer::Vendor::Lexisnexis' do
  include ClientRequestHelper

  describe 'all applicants' do
    it 'completes cycle' do
      all_applicants.each do |applicant|
        puts '=' * 80
        agent = Proofer::Agent.new vendor: :lexisnexis, applicant: applicant, verify_threshold: 0.25
        expect(agent.applicant).to be_a Proofer::Applicant

        resolution = agent.start
        expect(resolution).to be_a Proofer::Resolution
        if resolution.success
          puts "#{applicant.ssn} -> PASS"
          expect(resolution.success).to eq true

          answer_questions(resolution.questions)

          confirmation = agent.submit_answers(resolution.questions, resolution.session_id)
          expect(confirmation).to be_a Proofer::Confirmation
          expect(confirmation.success).to eq true
        else
          puts "#{applicant.ssn} -> FAIL"
          expect(resolution.success).to eq false
          expect(resolution.questions).to eq nil
        end
      end
    end
  end

  def answer_questions(question_set)
    question_set.each do |question|
      question.answer = 'NONE OF THE ABOVE'
    end
  end
end
