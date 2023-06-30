# frozen_string_literal: true

require 'open-uri'

module API
  # Connects to Snap OAuth API
  class MicrosoftGraphClient
    BASE_URL = "https://graph.microsoft.com/v1.0"
    TENANT_ID = Rails.configuration.x.azure.tenant_id

    # @param token [String]
    # @return [self]
    def initialize(token = nil)
      @token = token
      @client = Faraday.new(url: BASE_URL) do |faraday|
        faraday.headers = headers(token)
        faraday.request :json
        faraday.request :multipart
        faraday.request :instrumentation if Object.const_defined?(:ActiveSupport)
        faraday.response :json, parser_options: { symbolize_names: true }
        faraday.adapter :net_http
      end
    end

    # @param file [File]
    # @param  filename [String]
    # @return (see #put)
    def upload_file(file, filename)
      url = "sites/#{Rails.configuration.x.azure.drive_url}/#{filename}:/content"
      payload = {
        file: UploadIO.new(
          file,
          file.content_type
        )
      }
      put(url, payload)
    end

    # @param  filename [String]
    # @return (see #put)
    def download_file(filename)
      url = "#{BASE_URL}/sites/#{Rails.configuration.x.azure.drive_url}/#{filename}:/content"
      open(url, "Authorization" => "Bearer #{token}")
    end

    private

    attr_reader :client, :token

    # @param token [String, nil]
    # @return [Hash]
    def headers(token)
      {
        "Authorization" => "Bearer #{token}",
        "Content-Type" => "multipart/form-data"
      }.compact.freeze
    end

    # @return [Faraday::Response]
    def put(url, payload = {})
      client.put(url, payload)
    end
  end
end
