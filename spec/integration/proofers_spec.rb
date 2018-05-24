require 'csv'

describe 'LexisNexis Proofers' do
  before(:all) do
    Dotenv.overload('.env')
  end

  after(:all) do
    Dotenv.overload('.env.test')
  end

  CSV.parse(Fixtures.lexisnexis_test_data, headers: true).each_with_index do |datum, index|
    context "test case #{index}" do
      let(:applicant) do
        {
          uuid: SecureRandom.uuid,
          first_name: datum['first_name'],
          last_name: datum['last_name'],
          ssn: datum['ssn'],
          dob: datum['dob'],
          phone: datum['phone'],
        }
      end

      it 'proofs correctly with InstantVerify' do
        applicant.delete(:phone)

        result = LexisNexis::InstantVerify::Proofer.new.proof(applicant)

        if datum['result'] == 'pass'
          expect(result.success?).to eq(true)
        elsif datum['result'] == 'failed'
          expect(result.success?).to eq(false)
        else
          raise "Unexpected result type: #{result}"
        end
      end

      it 'proofs correctly for PhoneFinder' do
        result = LexisNexis::PhoneFinder::Proofer.new.proof(applicant)

        if datum['result'] == 'pass'
          expect(result.success?).to eq(true)
        elsif datum['result'] == 'failed'
          expect(result.success?).to eq(false)
        else
          raise "Unexpected result type: #{datum['result']}"
        end
      end
    end
  end
end
