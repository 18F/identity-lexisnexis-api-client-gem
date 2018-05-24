describe LexisNexis::InstantVerify::VerificationRequest do
  let(:attributes) do
    {
      uuid: '1234-abcd',
      first_name: 'Johnathan',
      last_name: 'Cooper',
      ssn: '123-45-6789',
      dob: '01/01/1980',
    }
  end
  let(:response_body) { Fixtures.instant_verify_success_response_json }
  subject { described_class.new(attributes) }

  it_behaves_like 'a request'

  describe '#body' do
    it 'returns a properly formed request body' do
      expect(subject.body).to eq(Fixtures.instant_verify_request_json)
    end
  end

  describe '#url' do
    it 'returns a url for the Instant Verify endpoint' do
      expect(subject.url).to eq('https://example.com/restws/identity/v2/test_account/customers.gsa.instant.verify.workflow/conversation')
    end
  end
end
