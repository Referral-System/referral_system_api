# Methods to Encode/Decode token from User
module Authable
  extend ActiveSupport::Concern

  included do
    # generate unique app_token for authorizing react app
    def create_app_token(user_id, opts = {})
      JwtAdapter.create_auth_token(user_id, opts)
    end

    # decode user payload from secure jwt token
    def decode_user_from_token(token)
      payload = JwtAdapter.decode(token)

      User.find_by id: payload[:sub]
    end
  end
end
