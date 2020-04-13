RSpec.describe LexisNexis::ThreatMetrix::Response do
  let(:response_status_code) { 200 }
  let(:response_body) { Fixtures.threat_metrix_response_json }
  let(:response_return_code) { :ok }
  let(:response) do
    Typhoeus::Response.new(
      code: response_status_code,
      body: response_body,
      return_code: response_return_code
    )
  end

  subject { LexisNexis::ThreatMetrix::Response.new(response) }

  describe '.new' do
    context 'when the request times out' do
      let(:response_return_code) { :operation_timedout }

      it 'raises a timeout error' do
        expect { subject }.to raise_error(
          Proofer::TimeoutError,
          'LexisNexis timed out waiting for verification response'
        )
      end
    end

    context 'with an HTTP status error code' do
      let(:response_status_code) { 500 }
      let(:response_body) { 'something went horribly wrong' }

      it 'raises an error that includes the status code and the body' do
        expect { subject }.to raise_error(
          LexisNexis::Response::UnexpectedHTTPStatusCodeError,
          "Unexpected status code '500': something went horribly wrong"
        )
      end
    end

    context 'with an invalid transaction status' do
      let(:response_body) do
        parsed_body = JSON.parse(super())
        parsed_body['review_status'] = 'fake_status'
        parsed_body.to_json
      end

      it 'raises an error that includes the transaction status code' do
        expect { subject }.to raise_error(
          LexisNexis::Response::UnexpectedVerificationStatusCodeError,
          "Invalid status in response body: 'fake_status'"
        )
      end
    end
  end

  describe '#verification_errors' do
    context 'with a failed verification' do
      let(:response_body) { Fixtures.threat_metrix_failure_response_json }
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
      let(:response_body) { Fixtures.threat_metrix_failure_response_json }
      it { expect(subject.verification_status).to eq('failed') }
    end
  end
end