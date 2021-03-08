describe LexisNexis::PhoneFinder::Proofer do
  let(:applicant) do
    {
      uuid_prefix: '0987',
      uuid: '1234-abcd',
      first_name: 'Testy',
      last_name: 'McTesterson',
      ssn: '123-45-6789',
      dob: '01/01/1980',
      phone: '5551231234',
    }
  end
  let(:verification_request) do
    LexisNexis::PhoneFinder::VerificationRequest.new(applicant: applicant, config: example_config)
  end

  it_behaves_like 'a proofer'

  subject(:instance) do
    LexisNexis::PhoneFinder::Proofer.new(**example_config.to_h)
  end

  describe '#proof' do
    subject(:result) { instance.proof(applicant) }

    before do
      stub_request(:post, verification_request.url).
        to_return(body: response_body, status: 200)
    end

    context 'when the response is a failure' do
      let(:response_body) { Fixtures.instant_verify_date_of_birth_full_fail_response_json }

      it 'is a failure result' do
        expect(result.success?).to eq(false)
        expect(result.errors).to include(
          base: include(a_kind_of(String)),
          'Execute Instant Verify': include(a_kind_of(Hash))
        )
      end
    end
  end
end
