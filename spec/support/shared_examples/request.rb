shared_examples 'a request' do |basic_auth: true|
  if basic_auth
    describe '#http_headers' do
      it 'contains the username and password' do
        credentials = Base64.strict_encode64('test_username:test_password')
        expected_value = "Basic #{credentials}"

        expect(subject.headers['Authorization']).to eq(expected_value)
      end
    end
  end

  describe '#send' do
    it 'returns a response object initialized with the http response' do
      http_response = Typhoeus::Response.new(code: 200, body: response_body)
      Typhoeus.stub(subject.url).and_return(http_response)

      verification_response = instance_double(LexisNexis::Response)
      expect(LexisNexis::Response).to receive(:new).
        with(http_response).
        and_return(verification_response)

      expect(subject.send).to eq(verification_response)
    end
  end
end
