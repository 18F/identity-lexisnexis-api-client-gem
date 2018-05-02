module Fixtures
  class << self
    def instant_verify_request_json
      raw = read_fixture_file_at_path('fixtures/instant_verify/request.json')
      JSON.parse(raw).to_json
    end

    def instant_verify_success_response_json
      raw = read_fixture_file_at_path('fixtures/instant_verify/successful_response.json')
      JSON.parse(raw).to_json
    end

    def instant_verify_failure_response_json
      raw = read_fixture_file_at_path('fixtures/instant_verify/failed_response.json')
      JSON.parse(raw).to_json
    end

    def instant_verify_error_response_json
      raw = read_fixture_file_at_path('fixtures/instant_verify/error_response.json')
      JSON.parse(raw).to_json
    end

    def phone_finder_request_json
      raw = read_fixture_file_at_path('fixtures/phone_finder/request.json')
      JSON.parse(raw).to_json
    end

    def phone_finder_success_response_json
      raw = read_fixture_file_at_path('fixtures/phone_finder/response.json')
      JSON.parse(raw).to_json
    end

    private

    def read_fixture_file_at_path(filepath)
      expanded_path = File.expand_path(filepath, __dir__)
      File.read(expanded_path)
    end
  end
end
