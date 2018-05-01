describe LexisNexis::InstantVerify::Proofer do
  let(:applicant) do
    {
      uuid: '1234-abcd',
      first_name: 'Johnathan',
      last_name: 'Cooper',
      ssn: '123456789',
      dob: '01/01/1980',
    }
  end
  let(:verification_request) { LexisNexis::InstantVerify::VerificationRequest.new(applicant) }

  it_behaves_like 'a proofer'
end
