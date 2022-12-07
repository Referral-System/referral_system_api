class AuthController < ApplicationController
    include Authable

    # GET /auth/:provider/callback
    # @return [void]
    def callback
        user = User.find_by(email: user_hash[:email])
        if user.nil?
            user = User.create(user_hash)
        else
            user.update(user_hash.except(:role_id))
        end
        app_token = create_app_token(user.id, { exp: 24.hours.from_now.to_i })
        redirect_url =  request.env['omniauth.params']['redirect_url'] || "/"
        redirect_to "#{redirect_url}?token=#{app_token}", allow_other_host: true
    end

    # @return [OmniAuth::AuthHash]
    def auth_hash
        request.env["omniauth.auth"]
    end

    # @return [Hash]
    def user_hash
        {
          email: auth_hash.dig(:info, :email),
          name: auth_hash.dig(:info, :name),
          active: true,
          role_id: 2
        }
    end
end

