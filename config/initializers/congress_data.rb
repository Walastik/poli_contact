Rails.application.configure do
  # Root path for unitedstates/congress JSON output (e.g., data/bills/*/data.json).
  # Defaults to a sibling directory named "congress-data" if not provided.
  config.congress_data_path =
    ENV["CONGRESS_DATA_PATH"].presence || Rails.root.join("congress-data").to_s
end

