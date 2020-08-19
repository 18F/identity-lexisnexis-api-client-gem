describe LexisNexis::VerificationErrorParser do
  let(:response_body) { JSON.parse(Fixtures.instant_verify_failure_response_json) }
  subject { described_class.new(response_body) }

  describe 'parsed_errors' do
    it 'should return an array of errors from the response' do
      errors = subject.parsed_errors

      expect(errors[:base]).to include("total.scoring.model.verification.fail")
      expect(errors[:base]).to include("31000123456789")
      expect(errors[:base]).to include("1234-abcd")

      expect(errors[:Discovery]).to eq(nil) # This should be absent since it passed
      expect(errors[:SomeOtherProduct]).to eq(response_body['Products'][1].to_json)
      expect(errors[:InstantVerify]).to eq(response_body['Products'][2].to_json)
    end
  end
end
