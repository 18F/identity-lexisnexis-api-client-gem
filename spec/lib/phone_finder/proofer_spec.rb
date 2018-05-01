describe LexisNexis::PhoneFinder::Proofer do
  let(:applicant) do
    {
      uuid: '1234-abcd',
      first_name: 'Johnathan',
      last_name: 'Cooper',
      ssn: '123456789',
      dob: '01/01/1980',
      phone: '5551231234',
    }
  end
  let(:verification_request) { LexisNexis::PhoneFinder::VerificationRequest.new(applicant) }

  it_behaves_like 'a proofer'
end
