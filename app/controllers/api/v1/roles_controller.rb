module Api
  module V1
    class RolesController < ApplicationController
      before_action :authenticate_user!
      load_and_authorize_resource

      swagger_controller :roles, "Roles Management Endpoints"

      swagger_api :index do
        summary "Fetches all Roles"
        notes "This lists all the available roles"
        response :ok
      end

      def index
        log_debug("Fetching all Roles")
        render json: Role.accessible_by(current_ability)
      end

      swagger_api :create do
        summary "Create a Roles"
        notes "This create a new role"
        param :form, :name, :string, :required, "Role name"
        response :created
        response :unprocessable_entity, "Parameter missing"
        response :internal_server_error, "Error while creating a new role"
      end

      def create
        # TODO: Implement validation to ensure only admin users can add new roles
        begin
          role = Role.new(role_params)
          if role.save
            log_debug("Creating role with name #{role.name}")
            render json: role, status: :created
          else
            log_error("Error while creating a new role")
            render json: role.errors, status: :unprocessable_entity
          end
        rescue ActionController::ParameterMissing => e
          log_error("Error while creating new role: #{e.message}")
          render json: {
            'message': "Parameter missing",
            'errors': e.message,
          }, status: :unprocessable_entity
        rescue StandardError => e
          log_error("Error while creating new role: #{e.message}")
          render json: {
            'message': "Error while creating a new role",
            'errors': e.message,
          }, status: :internal_server_error
        end
      end

      private

      def raise_error(message)
        log_error(message)
        render json: {
          'message': message,
        }, status: :unprocessable_entity
      end

      def role_params
        params.require(:name)
        params.permit(:name)
      end
    end
  end
end
