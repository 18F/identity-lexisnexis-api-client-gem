module LexisNexis
  class Client
    attr_reader :savon
    extend Forwardable
    def_delegators :savon, :call, :operations

    def initialize(opts = {})
      @savon = Savon.client(default_opts.merge(opts))
    end

    def default_opts
      {
        wsdl: ENV['LEXISNEXIS_WSDL'] || 'https://staging.identitymanagement.lexisnexis.com/identity-proofing/services/identityProofingServiceWS/v2?wsdl',
        env_namespace: :soapenv,
        logger: Logger.new(STDOUT),
        log_level: (ENV['LEXISNEXIS_DEBUG'] ? :debug : :warn),
        log: true,
        filters: [:password],
        pretty_print_xml: true,
        soap_header: {
          Security: {
            UsernameToken: {
              Username: ENV['LEXISNEXIS_USERNAME'],
              Password: ENV['LEXISNEXIS_PASSWORD'],
              Nonce: Base64.encode64(SecureRandom.hex(12)),
              Created: Time.now.iso8601
            }
          }
        }
      }
    end
  end
end
