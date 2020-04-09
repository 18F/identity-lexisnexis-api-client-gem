require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash'

describe LexisNexis::ThreatMetrix::VerificationRequest do
  let(:attributes) do
    {
      uuid: '1234-abcd',
      first_name: 'Testy',
      last_name: 'McTesterson',
      ssn: '123-45-6789',
      dob: '01/15/1980',
      address1: '123 Main St',
      address2: 'Ste 3',
      city: 'Baton Rouge',
      state: 'LA',
      zipcode: '70802-12345',
    }
  end
  let(:response_body) { Fixtures.threat_metrix_response_json }
  subject(:request) { described_class.new(attributes) }

  it_behaves_like 'a request', basic_auth: false

  describe '#body' do
    subject(:body) { request.body.with_indifferent_access }

    it 'has the right api_key' do
      expect(body[:api_key]).
        to eq(ENV.fetch('lexisnexis_threat_metrix_api_key')).and be_present
    end

    it 'has the right org_id' do
      expect(body[:org_id]).
        to eq(ENV.fetch('lexisnexis_threat_metrix_org_id')).and be_present
    end

    it 'does not specify a policy (uses default policy for now)' do
      expect(body).to_not have_key(:policy)
    end

    it 'hashes the SSN' do
      expect(body[:national_id_type]).to eq('US_SSN_HASH')
      expect(body[:national_id_number]).
        to eq('15e2b0d3c33891ebb0f1ef609ec419420c20e320ce94c65fbc8c3312448eb225')
    end

    it 'formats the date of birth correctly' do
      expect(body[:account_date_of_birth]).to eq('19800115')
    end
  end

  describe '#url' do
    it 'returns a url for the Instant Verify endpoint' do
      expect(subject.url).to eq('https://h-api.online-metrix.net/api/session-query')
    end
  end
end
