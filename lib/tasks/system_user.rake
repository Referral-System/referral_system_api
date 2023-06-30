# frozen_string_literal: true
namespace :system_user do
  desc "Add System User"
  task :create, %i[refresh_token] => :environment do |_t, args|
    puts("Please provide refresh token") and exit(1) if args.refresh_token.nil?

    token = args.refresh_token
    result = refresh_token(token)
    user = ReferralSystemEmailUser.first_or_create!(email: Rails.configuration.x.azure.user_email)
    user.update!(result)
    puts "System user created successfully"
  end

  private


  # @param token [String]
  # @return [Hash]
  def refresh_token(token)
    client = API::MicrosoftAuthClient.new
    response = client.refresh_token(token)
    puts("Error while refreshing token") and exit(1) unless response.success?

    build_system_user(response.body)
  end

  # @param body [Hash]
  # @return [Hash]
  def build_system_user(body)
    {
      email: Rails.configuration.x.azure.user_email,
      access_token: body[:access_token],
      refresh_token: body[:refresh_token],
      token_expires_at: Time.now.utc + body[:expires_in]
    }
  end
end
