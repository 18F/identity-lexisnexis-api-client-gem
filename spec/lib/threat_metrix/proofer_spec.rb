describe LexisNexis::ThreatMetrix::Proofer do
  let(:applicant) do
    {
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
  let(:verification_request) { LexisNexis::ThreatMetrix::VerificationRequest.new(applicant) }

  it_behaves_like 'a proofer'

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
  end
end
