describe LexisNexis::InstantVerify::Proofer do
  let(:applicant) do
    {
      uuid_prefix: '0987',
      uuid: '1234-abcd',
      first_name: 'Testy',
      last_name: 'McTesterson',
      ssn: '123456789',
      dob: '01/01/1980',
      address1: '123 Main St',
      address2: 'Ste 3',
      city: 'Baton Rouge',
      state: 'LA',
      zipcode: '70802-12345',
    }
  end
  let(:verification_request) { LexisNexis::InstantVerify::VerificationRequest.new(applicant) }
  subject(:proofer) { described_class.new }

  it_behaves_like 'a proofer'

  describe 'proofing birth year only' do
    let(:applicant) { super().merge(dob_year_only: true) }

    it 'does not send day or month in the birthday field' do
      stub_request(:post, verification_request.url).with do |request|
        body = JSON.parse(request.body, symbolize_names: true)
        expect(body.dig(:Person, :DateOfBirth)).to eq(Year: "1980")
      end.to_return(body: Fixtures.instant_verify_success_response_json, status: 200)

      subject.proof(applicant)
    end
  end

  describe '#send' do
    context 'when the request times out' do
      it 'raises a timeout error' do
        stub_request(:post, verification_request.url).to_timeout

        expect { verification_request.send }.to raise_error(
          Proofer::TimeoutError,
          'LexisNexis timed out waiting for verification response'
        )
      end
    end

    context 'when the request is made' do
      it 'it looks like the right request' do
        request = stub_request(:post, verification_request.url).
          with(body: verification_request.body, headers: verification_request.headers).
          to_return(body: Fixtures.instant_verify_success_response_json, status: 200)

        verification_request.send

        expect(request).to have_been_requested.once
      end
    end
  end
end
