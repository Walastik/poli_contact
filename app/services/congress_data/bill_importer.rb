require "json"

module CongressData
  class BillImporter
    # Import all bill JSON files found under the given root.
    def self.import_all!(root_path = Rails.application.config.congress_data_path)
      pattern = File.join(root_path.to_s, "**", "data.json")
      Dir.glob(pattern).sort.each do |path|
        import_file!(path)
      end
    end

    # Import a single bill JSON file.
    def self.import_file!(path)
      data = JSON.parse(File.read(path))

      congress   = data["congress"]
      bill_type  = data["bill_type"] || data["bill_type_label"] || data["bill_id"]&.split(".")&.first
      number     = data["number"] || data["bill_id"]&.split(".")&.last&.to_i

      bill = ::Bill.find_or_initialize_by(
        congress:,
        bill_type:,
        number:
      )

      bill.title       = data["title"] || data["official_title"]
      bill.short_title = data["short_title"]

      # Summary can be present as a string or nested under a hash depending on schema.
      bill.summary = if data["summary"].is_a?(Hash)
                       data["summary"]["text"] || data["summary"]["short"]
                     else
                       data["summary"]
                     end

      bill.introduced_on       = data["introduced_at"] || data["introduced_on"]
      bill.current_status      = data.dig("history", "status")
      bill.current_status_date = data.dig("history", "status_at") || data.dig("history", "acted_at")
      bill.source_path         = path

      bill.save!
    rescue JSON::ParserError => e
      Rails.logger.error("Failed to parse bill JSON at #{path}: #{e.message}")
    end
  end
end

