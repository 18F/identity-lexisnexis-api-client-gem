describe LexisNexis::PhoneFinder::Proofer do
  let(:applicant) do
    {
      uuid_prefix: '0987',
      uuid: '1234-abcd',
      first_name: 'Testy',
      last_name: 'McTesterson',
      ssn: '123-45-6789',
      dob: '01/01/1980',
      phone: '5551231234',
    }
  end
  let(:verification_request) { LexisNexis::PhoneFinder::VerificationRequest.new(applicant) }

  it_behaves_like 'a proofer'
end
