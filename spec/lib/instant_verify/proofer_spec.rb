describe LexisNexis::InstantVerify::Proofer do
  let(:applicant) do
    {
      uuid: '1234-abcd',
      first_name: 'Testy',
      last_name: 'McTesterson',
      ssn: '123456789',
      dob: '01/01/1980',
      address1: '123 Main St',
      address2: 'Ste 3',
      city: 'Baton Rouge',
      state: 'LA',
      zipcode: '70802-12345',
    }
  end
  let(:verification_request) { LexisNexis::InstantVerify::VerificationRequest.new(applicant) }

  it_behaves_like 'a proofer'
end
