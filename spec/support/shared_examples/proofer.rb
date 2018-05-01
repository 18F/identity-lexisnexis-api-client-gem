shared_examples 'a proofer' do
  let(:verification_status) { 'passed' }
  let(:verification_errors) { {} }
  let(:transaction_error) { nil }
  let(:result) { Proofer::Result.new }

  before do
    response = instance_double(LexisNexis::Response)
    allow(response).to receive(:verification_status).and_return(verification_status)
    allow(response).to receive(:verification_errors).and_return(verification_errors)
    allow(response).to receive(:transaction_error).and_return(transaction_error)

    allow(verification_request).to receive(:send).and_return(response)
    allow(verification_request.class).to receive(:new).
      with(applicant).
      and_return(verification_request)
  end

  describe '#proof_applicant' do
    context 'when proofing succeeds' do
      it 'results in a successful result' do
        subject.proof_applicant(applicant, result)

        expect(result.success?).to eq(true)
        expect(result.errors).to be_empty
      end
    end

    context 'when proofing fails' do
      let(:verification_status) { 'failed' }
      let(:verification_errors) do
        { base: 'test error', Discovery: 'another test error' }
      end

      it 'results in an unsuccessful result' do
        subject.proof_applicant(applicant, result)

        expect(result.success?).to eq(false)
        expect(result.errors).to eq(
          base: ['test error'],
          Discovery: ['another test error']
        )
      end
    end

    context 'when proofing results in an error' do
      let(:verification_status) { 'error' }
      let(:transaction_error) { LexisNexis::Response::ResponseError.new('test') }

      it 'raises the error' do
        expect { subject.proof_applicant(applicant, result) }.to raise_error(transaction_error)
      end
    end
  end
end