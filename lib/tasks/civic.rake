namespace :civic do
  desc "Import divisions, offices, and representatives for a given address"
  task :import_reps_for_address, [:address] => :environment do |_t, args|
    address = args[:address]
    unless address.present?
      puts "Usage: rake civic:import_reps_for_address['123 Main St, City, ST']"
      exit 1
    end

    client = GoogleCivic::Client.new
    response = client.representatives_for(address:)

    GoogleCivic::DivisionImporter.import!(response)
    GoogleCivic::RepresentativesImporter.import!(response)

    puts "Imported representatives for address: #{address}"
  end
end

