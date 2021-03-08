shared_examples 'a request' do |basic_auth: true|
  describe '#http_headers' do
    it 'contains the content type' do
      expect(subject.headers).to include('Content-Type' => 'application/json')
    end
  end

  describe '#send' do
    if basic_auth
      it 'includes the basic auth header' do
        credentials = Base64.strict_encode64('test_username:test_password')
        expected_value = "Basic #{credentials}"

        stub_request(:post, subject.url).
          to_return(status: 200, body: response_body)

        subject.send

        expect(a_request(:post, subject.url).with(headers: { 'Authorization' => expected_value })).
          to have_been_requested
      end
    end

    it 'returns a response object initialized with the http response' do
      stub_request(:post, subject.url).
        to_return(status: 200, body: response_body)

      verification_response = instance_double(LexisNexis::Response)
      expect(LexisNexis::Response).to receive(:new).
        with(kind_of(Faraday::Response), anything).
        and_return(verification_response)

      expect(subject.send).to eq(verification_response)
    end
  end
end
