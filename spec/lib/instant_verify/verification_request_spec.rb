require 'logger'

describe LexisNexis::InstantVerify::VerificationRequest do
  let(:attributes) do
    {
      uuid_prefix: '0987',
      uuid: '1234-abcd',
      first_name: 'Testy',
      last_name: 'McTesterson',
      ssn: '123-45-6789',
      dob: '01/01/1980',
      address1: '123 Main St',
      address2: 'Ste 3',
      city: 'Baton Rouge',
      state: 'LA',
      zipcode: '70802-12345',
    }
  end
  let(:response_body) { Fixtures.instant_verify_success_response_json }
  subject { described_class.new(attributes) }

  it_behaves_like 'a request'

  describe '#body' do
    it 'returns a properly formed request body' do
      expect(subject.body).to eq(Fixtures.instant_verify_request_json)
    end

    context 'without an address line 2' do
      let(:attributes) do
        hash = super()
        hash.delete(:address2)
        hash
      end

      it 'sets StreetAddress2 to and empty string' do
        parsed_body = JSON.parse(subject.body, symbolize_names: true)
        expect(parsed_body[:Person][:Addresses][0][:StreetAddress2]).to eq('')
      end
    end

    context 'without a uuid_prefix' do
      let(:attributes) do
        hash = super()
        hash.delete(:uuid_prefix)
        hash
      end

      it 'does not prepend' do
        parsed_body = JSON.parse(subject.body, symbolize_names: true)
        expect(parsed_body[:Settings][:Reference]).to eq(attributes[:uuid])
      end
    end

    context 'when dob_year_only is true' do
      let(:attributes) do
        super().merge(dob_year_only: true)
      end

      it 'does not send the birth month or day' do
        date_of_birth = JSON.parse(subject.body, symbolize_names: true).dig(:Person, :DateOfBirth)
        expect(date_of_birth).to_not include(:Month, :Day)
      end

      context 'when deployed in staging' do
        let(:logger) { Logger.new('/dev/null') }

        before do
          stub_const('LoginGov::Hostdata', double(env: 'staging'))
          stub_const('Rails', double(logger: logger))
        end

        it 'logs that it sent dob_year_only' do
          expect(logger).to receive(:info).with(/dob_year_only/)

          subject
        end
      end
    end
  end

  describe '#url' do
    it 'returns a url for the Instant Verify endpoint' do
      expect(subject.url).to eq('https://example.com/restws/identity/v2/test_account/customers.gsa.instant.verify.workflow/conversation')
    end
  end
end
