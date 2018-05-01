describe LexisNexis::Response do
  let(:response_body) { Fixtures.instant_verify_success_response_json }
  subject { LexisNexis::Response.new(response_body) }

  describe '#transaction_error' do
    context 'with an error' do
      let(:response_body) { Fixtures.instant_verify_error_response_json }

      it 'returns an error that includes the reason code and information from the reponse' do
        error = subject.transaction_error

        expect(error.message).to include(
          "Response error with code 'invalid_transaction_initiate'"
        )
        expect(error.message).to include(JSON.parse(response_body)['Information'].to_json)
      end
    end

    context 'without an error' do
      it { expect(subject.transaction_error).to eq(nil) }
    end
  end

  describe '#verification_errors' do
    context 'with a failed verification' do
      let(:response_body) { Fixtures.instant_verify_failure_response_json }
      it 'returns a hash of errors' do
        errors = subject.verification_errors

        expect(errors).to be_a(Hash)
        expect(errors).to include(:base, :SomeOtherProduct, :InstantVerify)
      end
    end

    context 'with a passed verification' do
      it { expect(subject.verification_errors).to eq({}) }
    end
  end

  describe '#verification_status' do
    context 'passed' do
      it { expect(subject.verification_status).to eq('passed') }
    end

    context 'failed' do
      let(:response_body) { Fixtures.instant_verify_failure_response_json }
      it { expect(subject.verification_status).to eq('failed') }
    end

    context 'error' do
      let(:response_body) { Fixtures.instant_verify_error_response_json }
      it { expect(subject.verification_status).to eq('error') }
    end

    context 'unrecognized status' do
      let(:response_body) { { Status: { TransactionStatus: 'pending' } }.to_json }

      it 'raises an error' do
        expect { subject.verification_status }.to raise_error(
          LexisNexis::Response::ResponseError,
          "Invalid status in response body: 'pending'"
        )
      end
    end
  end
end
