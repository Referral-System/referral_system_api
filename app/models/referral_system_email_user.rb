class ReferralSystemEmailUser < ApplicationRecord
  validates :email,
            presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "Invalid e-mail address" },
            uniqueness: { case_sensitive: false },
            length: { minimum: 8, maximum: 254 }

  encrypts :access_token, :refresh_token

  # Refreshes Snap access token if expired
  # @return [String]
  def current_access_token
    expired_token? ? refresh_token! : access_token
  end

  # Forces to update Snap access token
  # @return [String]
  def current_access_token!
    refresh_token!
  end

  # @return [Boolean]
  def expired_token?
    Time.now.utc >= (token_expires_at || updated_at)
  end

  # Refresh an expired token. This method should be temporal
  # @return [String, FalseClass] new access token in successful refresh, false otherwise
  def refresh_token!
    client = API::MicrosoftAuthClient.new
    response = client.refresh_token(refresh_token)
    unless response.success?
      Rails.logger.error("Error refreshing token.")
      return false
    end

    update!(
      access_token: response.body[:access_token],
      refresh_token: response.body[:refresh_token],
      token_expires_at: Time.now.utc + response.body[:expires_in]
    )
    response.body[:access_token]
  end
end
