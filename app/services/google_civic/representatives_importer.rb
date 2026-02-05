module GoogleCivic
  class RepresentativesImporter
    # Imports offices, people, and office holdings from a Google Civic API response.
    # Works with voterinfo format (contests with candidates) or representatives format.
    #
    # response - Parsed JSON from GoogleCivic::Client#voter_info_for or #representatives_for.
    def self.import!(response)
      # Ensure divisions exist first.
      DivisionImporter.import!(response)

      # Handle voterinfo format (contests with candidates)
      if response["contests"]
        import_from_contests!(response["contests"])
        return
      end

      # Handle representatives format (if it existed)
      divisions = response["divisions"] || {}
      offices   = response["offices"] || []
      officials = response["officials"] || []

      offices.each_with_index do |office_data, office_index|
        division = find_division_for_office(office_data, divisions)
        next unless division

        office = ::Office.find_or_initialize_by(
          division:,
          name: office_data["name"]
        )
        office.role = office_data["roles"]&.first
        office.google_civic_office_id ||= "office-#{office_index}"
        office.save!

        (office_data["officialIndices"] || []).each do |official_index|
          official = officials[official_index]
          next unless official

          person = find_or_build_person(official)
          person.save!

          ::OfficeHolding.find_or_create_by!(
            office:,
            person:,
            start_date: nil,
            end_date: nil
          )
        end
      end
    end

    def self.import_from_contests!(contests)
      contests.each do |contest|
        office_name = contest["office"]
        district_id = contest.dig("district", "id")
        next unless office_name && district_id

        # Find or create division from district OCD ID
        ocd_id = district_id.start_with?("ocd-division/") ? district_id : "ocd-division/#{district_id}"
        division = ::Division.find_by(ocd_id:)
        next unless division

        # Create office
        office = ::Office.find_or_initialize_by(
          division:,
          name: office_name
        )
        office.role = contest["roles"]&.first
        office.save!

        # Create people from candidates
        (contest["candidates"] || []).each do |candidate|
          person = find_or_build_person_from_candidate(candidate)
          person.save!

          ::OfficeHolding.find_or_create_by!(
            office:,
            person:,
            start_date: nil,
            end_date: nil
          )
        end
      end
    end
    private_class_method :import_from_contests!

    def self.find_division_for_office(office_data, divisions_hash)
      division_id = office_data["divisionId"]
      return unless division_id

      ::Division.find_by(ocd_id: division_id)
    end
    private_class_method :find_division_for_office

    def self.find_or_build_person_from_candidate(candidate)
      ::Person.find_or_initialize_by(
        name: candidate["name"]
      ).tap do |person|
        person.party     = candidate["party"] if candidate["party"].present?
        person.photo_url = candidate["photoUrl"] if candidate["photoUrl"].present?
        person.email     = candidate["email"] if candidate["email"].present?
        person.phone     = candidate["phone"] if candidate["phone"].present?
        person.url       = candidate["candidateUrl"] if candidate["candidateUrl"].present?
      end
    end
    private_class_method :find_or_build_person_from_candidate

    def self.find_or_build_person(official)
      ::Person.find_or_initialize_by(
        google_civic_person_id: official["id"]
      ).tap do |person|
        person.name      = official["name"] if official["name"].present?
        person.party     = official["party"] if official["party"].present?
        person.photo_url = official["photoUrl"] if official["photoUrl"].present?
        person.email     = Array(official["emails"]).first if official["emails"]
        person.phone     = Array(official["phones"]).first if official["phones"]
        person.url       = Array(official["urls"]).first if official["urls"]

        if official["address"]
          person.address_json = official["address"]
        end
      end
    end
    private_class_method :find_or_build_person
  end
end

