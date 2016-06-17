require 'csv'
require 'lexisnexis/applicant'

module ClientRequestHelper
  def all_applicants
    applicants = []
    row_count = 0
    CSV.foreach(ENV['LEXISNEXIS_TEST_CASES']) do |row|
      row_count += 1
      ssn = row[2]
      next unless ssn =~ /^\d+$/
      if ENV['USE_ROWS'] && !ENV['USE_ROWS'].split(/,/).include?(row_count.to_s)
        next
      end
      applicants << build_applicant(row)
    end
    applicants
  end

  def build_applicant(row)
    #puts row.pretty_inspect
    applicant = LexisNexis::Applicant.new(
      first_name: row[0],
      last_name: row[1],
      ssn: row[2],
      dob: {
        year: row[5],
        month: row[3],
        day: row[4]
      },
      address: {
        line_1: row[6],
        city: row[7],
        state: row[8],
        zip_code: row[9]
      }
    )
  end
end
