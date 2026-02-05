module GoogleCivic
  class DivisionImporter
    # Upsert Division records from the Google Civic API response.
    # Works with both voterinfo (contests[].district.id) and representatives (divisions hash) formats.
    def self.import!(response)
      # Try voterinfo format first (contests with district OCD IDs)
      if response["contests"]
        import_from_contests!(response["contests"])
      end
      
      # Also handle representatives format if present
      divisions = response["divisions"] || {}
      divisions.each do |ocd_id, attrs|
        name = attrs["name"]

        record = ::Division.find_or_initialize_by(ocd_id:)
        record.name = name if name.present?
        record.level ||= infer_level_from_ocd_id(ocd_id)

        # Simple parsing of common pieces for convenience.
        parts = ocd_id.split("/")
        record.country = parts.find { |p| p.start_with?("country:") }&.split(":", 2)&.last
        record.state   = parts.find { |p| p.start_with?("state:") }&.split(":", 2)&.last
        record.county  = parts.find { |p| p.start_with?("county:") }&.split(":", 2)&.last
        record.district = parts.find { |p| p.include?("cd:") }&.split(":", 2)&.last

        record.save!
      end
    end

    def self.import_from_contests!(contests)
      contests.each do |contest|
        district_id = contest.dig("district", "id")
        next unless district_id
        
        # Build OCD ID from district info
        # Note: voterinfo district.id might not be a full OCD ID, so we'll use what we have
        ocd_id = district_id.start_with?("ocd-division/") ? district_id : "ocd-division/#{district_id}"
        
        record = ::Division.find_or_initialize_by(ocd_id:)
        record.name = contest.dig("district", "name") || contest["office"]
        record.level ||= infer_level_from_ocd_id(ocd_id)
        record.save!
      end
    end
    private_class_method :import_from_contests!

    def self.infer_level_from_ocd_id(ocd_id)
      return "country" if ocd_id.include?("/country:")
      return "administrativeArea1" if ocd_id.include?("/state:")
      return "administrativeArea2" if ocd_id.include?("/county:")

      "district"
    end
    private_class_method :infer_level_from_ocd_id
  end
end

