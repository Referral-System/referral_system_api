module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_user!
      load_and_authorize_resource

      swagger_controller :users, "Users Management Endpoints"

      swagger_api :authorize do
        summary "Get authorized user"
        notes "This retrieve authenticated user"
        param :header, 'access-token', :string, :required, "Access Token"
        response :ok
        response :unauthorized, "Not Authorized"
      end
      def authorize
        render json: { user: @current_user }
      end

      swagger_api :index do
        summary "Fetches all Users"
        notes "This lists all the available users"
        response :ok
      end
      def index
        render json: User.where(active: true).accessible_by(current_ability), except: [:active, :created_at, :updated_at]
      end

      swagger_api :create do
        summary "Create a User"
        notes "This create a new user"
        param :form, :name, :string, :required, "User name"
        param :form, :email, :string, :required, "User email"
        param :form, :role_id, :integer, :required, "User role id"
        response :created
        response :unprocessable_entity, "Error while creating a new user"
        response :internal_server_error, "Error while creating a new role"
      end
      def create
        # TODO: Verify if user has permissions to set role of the new user
        begin
          user = User.new(user_params)
          unless role_not_allowed
            if user.save
              render json: user, except: [:active, :created_at, :updated_at], status: :created
            else
              render json: {
                'message': 'Error while creating a new user',
                'errors': user.errors
              }, status: :unprocessable_entity
            end
          end
        rescue StandardError => e
          Rails.logger.error("Error while creating a new user: #{e.message}")
          render json: {
            'message': 'Error while creating a new record',
            'errors': [e.message]
          }, status: :internal_server_error
        end
      end

      swagger_api :show do
        summary "Fetch a User"
        notes "This list a specific user"
        param :path, :id, :integer, :required, "User id"
        response :ok
        response :not_found, "Record not found"
        response :internal_server_error, "Error while retrieving record"
      end
      def show
        begin
          unless invalid_params_error
            user = User.find(params[:id])
            if user.active
              render json: user, status: :ok, except: [:active, :created_at, :updated_at]
            else
              render json: user.errors, status: :not_found
            end
          end
        rescue ActiveRecord::RecordNotFound => e
          render json: {
            'message': 'Record not found',
            'errors': [e.message]
          }, status: :not_found
        rescue StandardError => e
          Rails.logger.error("Error while retrieving user #{e.message}")
          render json: {
            'message': 'Error while retrieving record',
            'errors': [e.message]
          }, status: :internal_server_error
        end
      end

      swagger_api :update do
        summary "Update a User"
        notes "This update an existing user"
        param :path, :id, :integer, :required, "User id"
        param :form, :name, :string, :optional, "User name"
        param :form, :email, :string, :optional, "User email"
        param :form, :role_id, :integer, :required, "User role id"
        response :ok
        response :unprocessable_entity, "Error while creating a new user"
        response :internal_server_error, "Error while creating a new role"
      end
      def update
        begin
          unless invalid_params_error || role_not_allowed
            user = User.find(params[:id])

            if user.update(user_params)
              render json: user, except: [:active, :created_at, :updated_at], status: :ok
            else
              render json: user.errors, status: :unprocessable_entity
            end
          end
        rescue ActiveRecord::RecordNotFound => e
          render json: {
            'message': 'Record not found',
            'errors': [e.message]
          }, status: :not_found
        rescue StandardError => e
          Rails.logger.error("Error while retrieving user #{e.message}")
          render json: {
            'message': 'Error while retrieving record',
            'errors': [e.message]
          }, status: :internal_server_error
        end
      end

      swagger_api :destroy do
        summary "Delete a User"
        notes "This delete a specific user"
        param :path, :id, :integer, :required, "User id"
        response :ok
        response :unprocessable_entity
        response :not_found, "Record not found"
        response :internal_server_error, "Error while deleting user"
      end
      def destroy
        begin
          unless invalid_params_error
            user = User.find(params[:id])
            if user.update(active: false)
              render json: {
                'message': 'User successfully deleted.'
              }, status: :ok
            else
              render json: user.errors, status: :unprocessable_entity
            end
          end
        rescue ActiveRecord::RecordNotFound => e
          render json: {
            'message': 'Record not found',
            'errors': [e.message]
          }, status: :not_found
        rescue StandardError => e
          Rails.logger.error("Error while deleting user: #{e.message}")
          render json: {
            'message': 'Error while deleting user',
            'errors': [e.message]
          }, status: :internal_server_error
        end
      end

      private

      def user_params
        params.permit([:name, :email, :role_id])
      end

      def invalid_params_error
        unless params[:id].match? /\A\d+\z/
          message = 'ID is not a numeric value'
          Rails.logger.error(message)
          render json: {
            'message': 'Invalid parameter',
            'errors': [message]
          }, status: :unprocessable_entity
        end
      end

      def role_not_allowed
        message = 'Role not allowed'
        Rails.logger.error(message)
        render json: {
          'message': message,
          'errors': ['Creation of new admin users is not allowed']
        }, status: :forbidden if Role.find(params[:role_id]).name == 'admin'
      end
    end
  end
end
