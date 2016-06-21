require 'date'
require 'hashie/mash'

module LexisNexis
  class Applicant < Hashie::Mash
    def self.from_proofer_applicant(applicant)
      new(
        first_name: applicant.first_name,
        last_name: applicant.last_name,
        ssn: applicant.ssn,
        dob: self.format_dob(applicant.dob),
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

    def self.format_dob(dob)
      if dob.nil? || dob == ''
        { year: '', month: '', day: '' }
      elsif dob =~ /^\d+$/
        { year: dob.slice(0, 4), month: dob.slice(4, 2), day: dob.slice(6, 2) }
      else
        date = Date.parse(dob)
        { year: date.year, month: date.month, day: date.day }
      end
    end
  end
end
