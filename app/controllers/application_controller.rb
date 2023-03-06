class ApplicationController < ActionController::API
  include Authable
  include DbLogger

  before_action :cors_set_access_control_headers

  rescue_from CanCan::AccessDenied do |exception|
    log_error("User has not the correct permissions, request was unauthorized")
    render json: { message: "Unauthorized by CanCan" },status: 401
  end

  def cors_preflight_check
    if request.method == 'OPTIONS'
      cors_set_access_control_headers
      render text: '', content_type: 'text/plain'
    end
  end

  protected

  attr_reader :current_user

  # Extract access-token from headers and sets :current_user reader
  # @return [void]
  def authenticate_user!
    token = request.authorization.split(' ').last
    log_error("Token is missing, request was unauthorized")
    return render(json: { message: "Token is missing" }, status: :unauthorized) if token.nil?

    payload = JwtAdapter.decode(token)
    @current_user = User.find(payload[:sub])
  rescue JWT::VerificationError, JWT::DecodeError
    log_error("Incorrect JWT token, request was unauthorized")
    render json: { message: "Unauthorized" }, status: :unauthorized
  rescue ActiveRecord::RecordNotFound
    log_debug("User was not found, request was unauthorized")
    render json: { message: "User not found" }, status: :unauthorized
  rescue StandardError => e
    log_debug("Error while authorization, request was unauthorized")
    render json: {}, status: :internal_server_error
  end

  def cors_set_access_control_headers
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, PATCH, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token, Auth-Token, Email, X-User-Token, X-User-Email'
    response.headers['Access-Control-Max-Age'] = '1728000'
  end
end
