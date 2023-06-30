# frozen_string_literal: true

Rails.application.configure do
  # Azure ids
  config.x.azure.tap do |m|
    m.tenant_id     = ENV.fetch("AAD_TENANT", nil)
    m.client_id     = ENV.fetch("AAD_CLIENT_ID", nil)
    m.client_secret = ENV.fetch("AAD_CLIENT_SECRET", nil)
    m.user_email    = ENV.fetch("AAD_USER_EMAIL", nil)
    m.drive_url     = ENV.fetch("SP_DRIVE_URL", nil)
  end
end
