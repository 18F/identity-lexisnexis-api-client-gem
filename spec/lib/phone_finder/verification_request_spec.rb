describe LexisNexis::PhoneFinder::VerificationRequest do
  let(:attributes) do
    {
      uuid: '1234-abcd',
      first_name: 'Testy',
      last_name: 'McTesterson',
      ssn: '123456789',
      dob: '01/01/1980',
      phone: '5551231234',
    }
  end
  let(:response_body) { Fixtures.phone_finder_success_response_json }
  subject { described_class.new(attributes) }

  it_behaves_like 'a request'

  describe '#body' do
    it 'returns a properly formed request body' do
      expect(subject.body).to eq(Fixtures.phone_finder_request_json)
    end
  end

  describe '#url' do
    it 'returns a url for the Phone Finder endpoint' do
      expect(subject.url).to eq('https://example.com/restws/identity/v2/test_account/customers.gsa.phonefinder.workflow/conversation')
    end
  end
end
