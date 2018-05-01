shared_examples 'a request' do
  describe '#http_headers' do
    it 'contains the username and password' do
      credentials = Base64.strict_encode64('test_username:test_password')
      expected_value = "Basic #{credentials}"

      expect(subject.headers['Authorization']).to eq(expected_value)
    end
  end

  describe '#send' do
    context 'when the request is successful' do
      before do
        response = Typhoeus::Response.new(
          code: 200,
          body: response_body
        )
        Typhoeus.stub(subject.url).and_return(response)
      end

      it 'returns a response object initialized with the response body' do
        verification_response = instance_double(LexisNexis::Response)

        expect(LexisNexis::Response).to receive(:new).
          with(response_body).
          and_return(verification_response)

        expect(subject.send).to eq(verification_response)
      end
    end

    context 'when the request is not successful' do
      before do
        response = Typhoeus::Response.new(
          code: 500,
          body: 'The request failed for some reason'
        )
        Typhoeus.stub(subject.url).and_return(response)
      end

      it 'raises an error' do
        expect { subject.send }.to raise_error(
          LexisNexis::RequestError,
          "Unexpected status code '500': The request failed for some reason"
        )
      end
    end
  end
end
