class HomeController < ApplicationController
  def index
    @address = params[:address].to_s.strip

    if @address.present?
      begin
        client = GoogleCivic::Client.new
        response = client.representatives_for(address: @address)
        GoogleCivic::DivisionImporter.import!(response)
        GoogleCivic::RepresentativesImporter.import!(response)

        @divisions = Division.where(ocd_id: response.fetch("divisions", {}).keys)
        @office_holdings = OfficeHolding
          .includes(:office, :person)
          .joins(:office)
          .where(offices: { division_id: @divisions.select(:id) })

        # Very simple example: show most recent bills regardless of affiliation.
        @bills = Bill.recent
      rescue StandardError => e
        Rails.logger.error("Error fetching representatives: #{e.class} - #{e.message}")
        Rails.logger.error(e.backtrace.join("\n")) if e.backtrace
        @error_message = "We couldn't fetch civic data for that address. Please check the address and try again."
        @divisions = Division.none
        @office_holdings = OfficeHolding.none
        @bills = Bill.recent
      end
    else
      @divisions = Division.none
      @office_holdings = OfficeHolding.none
      @bills = Bill.recent
    end
  end
end

