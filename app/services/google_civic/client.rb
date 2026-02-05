module GoogleCivic
  class Error < StandardError; end

  class Client
    # Base URL for the Google Civic Information API v2 (REST).
    # See: https://developers.google.com/civic-information/docs/v2
    BASE_URL = "https://www.googleapis.com/civicinfo/v2".freeze

    def initialize(api_key: ENV.fetch("GOOGLE_CIVIC_API_KEY", nil))
      @api_key = api_key
      raise Error, "GOOGLE_CIVIC_API_KEY is not set" if @api_key.blank?

      @connection = Faraday.new(url: BASE_URL) do |f|
        f.response :json, content_type: /\bjson$/
        f.adapter Faraday.default_adapter
      end
    end

    # Get voter information which includes contests (elections) with candidates.
    # Note: The representatives endpoint doesn't exist in the current API.
    # This uses voterinfo which returns election contests and candidates.
    def voter_info_for(address:, election_id: nil)
      params = { address:, key: @api_key }
      params[:electionId] = election_id if election_id.present?
      
      response = @connection.get("divisionsByAddress", params)

      unless response.success?
        error_body = response.body
        error_msg = error_body.is_a?(Hash) ? error_body.dig("error", "message") : error_body.to_s
        
        message = +"Google Civic API error: HTTP #{response.status}"
        message << " – #{error_msg}" if error_msg.present?
        
        if response.status == 404
          message << "\n\nThis usually means the 'Google Civic Information API' is not enabled for your API key."
          message << "\nPlease enable it at: https://console.cloud.google.com/apis/library/civicinfo.googleapis.com"
        end
        
        raise Error, message
      end

      response.body
    end

    # Legacy method name - maps to voter_info_for for backwards compatibility.
    # Note: The representatives endpoint doesn't exist, so we use voterinfo instead.
    def representatives_for(address:)
      voter_info_for(address:)
    end
  end
end

