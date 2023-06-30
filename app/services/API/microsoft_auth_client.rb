# frozen_string_literal: true

module API
  # Connects to Snap OAuth API
  class MicrosoftAuthClient
    BASE_URL = "https://login.microsoftonline.com"
    TENANT_ID = Rails.configuration.x.azure.tenant_id

    # @return [self]
    def initialize
      @client = Faraday.new(url: BASE_URL) do |faraday|
        faraday.headers = headers
        faraday.request :json
        faraday.request :instrumentation if Object.const_defined?(:ActiveSupport)
        faraday.response :json, parser_options: { symbolize_names: true }
        faraday.adapter :net_http
      end
    end

    # @param token [String]
    # @return (see #post)
    def refresh_token(token)
      url = "#{TENANT_ID}/oauth2/v2.0/token"
      payload = {
        client_id: Rails.configuration.x.azure.client_id,
        client_secret: Rails.configuration.x.azure.client_secret,
        refresh_token: token,
        grant_type: "refresh_token"
      }

      post(url, payload)
    end

    private

    attr_reader :client

    # @return [Hash]
    def headers
      {
        "Accept" => "application/json",
        "Content-Type" => "application/x-www-form-urlencoded"
      }.compact.freeze
    end

    # @return [Faraday::Response]
    def post(url, payload = {})
      client.post(url, URI.encode_www_form(payload))
    end
  end
end
