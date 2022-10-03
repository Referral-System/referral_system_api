# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :azure_oauth2,
   {
     client_id: ENV['AAD_CLIENT_ID'],
     client_secret: ENV['AAD_CLIENT_SECRET'],
     tenant_id: ENV['AAD_TENANT']
   }
  end
