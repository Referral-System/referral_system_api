module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_user!
      load_and_authorize_resource

      swagger_controller :users, "Users Management Endpoints"

      swagger_api :authorize do
        summary "Get authorized user"
        notes "This retrieve authenticated user"
        param :header, "access-token", :string, :required, "Access Token"
        response :ok
        response :unauthorized, "Not Authorized"
      end

      def authorize
        Rails.logger.debug("Retrieving user with email #{@current_user.email}")
        render json: { user: @current_user }
      end

      swagger_api :index do
        summary "Fetches all Users"
        notes "This lists all the available users"
        response :ok
      end

      def index
        Rails.logger.debug("Fetching all Users")
        render json: User.where(active: true).accessible_by(current_ability),
          except: %i[active created_at updated_at]
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

        user = User.new(user_params)
        unless role_not_allowed
          if user.save
            Rails.logger.debug("Creating user with email #{user.email}")
            render json: user, except: %i[active created_at updated_at], status: :created
          else
            Rails.logger.error("Error while creating a new user")
            render json: {
              'message': "Error while creating a new user",
              'errors': user.errors,
            }, status: :unprocessable_entity
          end
        end
      rescue StandardError => e
        Rails.logger.error("Error while creating a new user: #{e.message}")
        render json: {
          'message': "Error while creating a new record",
          'errors': [e.message],
        }, status: :internal_server_error
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
        unless invalid_params_error
          user = User.find(params[:id])
          if user.active
            Rails.logger.debug("Fetching user with email #{user.email}")
            render json: user, status: :ok, except: %i[active created_at updated_at]
          else
            Rails.logger.error("Error fetching user with id #{params[:id]}")
            render json: user.errors, status: :not_found
          end
        end
      rescue ActiveRecord::RecordNotFound => e
        render json: {
          'message': "Record not found",
          'errors': [e.message],
        }, status: :not_found
      rescue StandardError => e
        Rails.logger.error("Error while retrieving user #{e.message}")
        render json: {
          'message': "Error while retrieving record",
          'errors': [e.message],
        }, status: :internal_server_error
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
        unless invalid_params_error
          user = User.find(params[:id])
          user_role_id = user.role_id

          if user.update(user_params)
            Referral.where(ta_recruiter: user.id).update_all(ta_recruiter: nil) if (user_params["role_id"] != 3 && user_role_id == 3)
            Rails.logger.debug("Updating user with email #{user.email}")
            render json: user, except: %i[active created_at updated_at], status: :ok
          else
            Rails.logger.error("Error updating user with id #{params[:id]}")
            render json: user.errors, status: :unprocessable_entity
          end
        end
      rescue ActiveRecord::RecordNotFound => e
        render json: {
          'message': "Record not found",
          'errors': [e.message],
        }, status: :not_found
      rescue StandardError => e
        Rails.logger.error("Error while retrieving user #{e.message}")
        render json: {
          'message': "Error while retrieving record",
          'errors': [e.message],
        }, status: :internal_server_error
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
        unless invalid_params_error
          user = User.find(params[:id])

          if user.update(active: false)
            Referral.where(ta_recruiter: user.id).update_all(ta_recruiter: nil) if (user.role_id == 3)
            Rails.logger.debug("Deleting user with email #{user.email}")
            render json: {
              'message': "User successfully deleted.",
            }, status: :ok
          else
            Rails.logger.error("Error while deleting user with id #{params[:id]}")
            render json: user.errors, status: :unprocessable_entity
          end
        end
      rescue ActiveRecord::RecordNotFound => e
        render json: {
          'message': "Record not found",
          'errors': [e.message],
        }, status: :not_found
      rescue StandardError => e
        Rails.logger.error("Error while deleting user: #{e.message}")
        render json: {
          'message': "Error while deleting user",
          'errors': [e.message],
        }, status: :internal_server_error
      end

      swagger_api :recruiters do
        summary "Fetches all Recruiters"
        notes "This lists all the available recruiters"
        response :ok
      end

      def recruiters
        render json: User.recruiters.where(active: true), except: %i[active created_at updated_at]
      end

      private

      def user_params
        params.permit(%i[name email role_id])
      end

      def invalid_params_error
        return if params[:id].match?(/\A\d+\z/)

        message = "ID is not a numeric value"
        Rails.logger.error(message)
        render json: {
          'message': "Invalid parameter",
          'errors': %i[message],
        }, status: :unprocessable_entity
      end

      def role_not_allowed
        message = "Role not allowed"
        Rails.logger.error(message)

        return unless Role.find(params[:role_id]).name == "admin"

        render json: {
          'message': message,
          'errors': ["Creation of new admin users is not allowed"],
        }, status: :forbidden
      end
    end
  end
end
