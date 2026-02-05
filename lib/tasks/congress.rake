namespace :congress do
  namespace :import do
    desc "Import all bill JSON files from the configured congress data path or a custom root"
    task :bills, [:root_path] => :environment do |_t, args|
      root = args[:root_path].presence || Rails.application.config.congress_data_path
      puts "Importing bills from: #{root}"
      CongressData::BillImporter.import_all!(root)
      puts "Bill import complete."
    end
  end
end

