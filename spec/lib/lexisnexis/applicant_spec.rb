require 'spec_helper'
require 'lexisnexis/applicant'
require 'proofer/applicant'

describe LexisNexis::Applicant do
  describe '#new' do
    it 'acts like a hash' do
      applicant = LexisNexis::Applicant.new foo: 'bar'
      expect(applicant.foo).to eq 'bar'
    end
  end

  describe '#from_proofer_applicant' do
    it 'coerces Proofer::Applicant' do
      proofer_applicant = Proofer::Applicant.new first_name: 'Some', address1: '123 Main', dob: '19720329'
      ln_applicant = LexisNexis::Applicant.from_proofer_applicant(proofer_applicant)
      expect(ln_applicant.address[:line_1]).to eq '123 Main'
      expect(ln_applicant.dob[:year]).to eq '1972'
      expect(ln_applicant.dob[:month]).to eq '03'
      expect(ln_applicant.dob[:day]).to eq '29'
    end
  end
end
