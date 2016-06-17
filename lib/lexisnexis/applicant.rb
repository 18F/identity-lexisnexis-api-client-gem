require 'hashie/mash'

module LexisNexis
  class Applicant < Hashie::Mash
    def self.from_proofer_applicant(applicant)
      new(
        first_name: applicant.first_name,
        last_name: applicant.last_name,
        ssn: applicant.ssn,
        dob: {
          year: applicant.dob.slice(0, 4),
          month: applicant.dob.slice(4, 2),
          day: applicant.dob.slice(6, 2)
        },
        phone: applicant.phone,
        address: {
          line_1: applicant.address1,
          line_2: applicant.address2,
          city: applicant.city,
          state: applicant.state,
          zip_code: applicant.zipcode
        }
      )
    end
  end
end
