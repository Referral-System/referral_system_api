module Api
  module V1
    class ReferralsController < ApplicationController
      before_action :authenticate_user!
      load_and_authorize_resource

      swagger_controller :referrals, "Referrals Management Endpoints"

      swagger_api :index do
        summary "Fetches all Referrals users"
        notes "This lists all the referrals users"
        response :ok
      end
      def index
        referrals = Referral.accessible_by(current_ability)
        render json: referrals, except: [:active, :created_at, :updated_at]
      end
    
      swagger_api :create do
        summary "Create a Referral"
        notes "This create a new referral"
        param :form, :referred_by, :integer, :optional, "Refered by user ID"
        param :form, :full_name, :string, :optional, "Full name of referred used"
        param :form, :phone_number, :string, :optional, "Phone number of referred used"
        param :form, :email, :string, :optional, "Email of referred used"
        param :form, :linkedin_url, :string, :optional, "Linkedin url of referred used"
        param :form, :cv_url, :string, :optional, "Cv url of referred used"
        param :form, :tech_stack, :string, :optional, "Tech stack of referred used"
        param :form, :ta_recruiter, :integer, :optional, "Ta recruiter ID"
        param :form, :status, :integer, :optional, "Status of referred used"
        param :form, :comments, :string, :optional, "Comments for referral"
        param :form, :active, :boolean, :optional, "Referral is active"
        response :created
        response :unprocessable_entity, "Error while creating a new referral"
        response :internal_server_error, "Error while creating a new record"
      end
      def create
        begin
          referral = Referral.new(referral_params)
          if referral.save
            render json: referral, except: [:created_at, :updated_at], status: :created
          else
            render json: {
              'message': 'Error while creating a new referral',
              'errors': referral.errors
            }, status: :unprocessable_entity
          end
        rescue StandardError => e
          Rails.logger.error("Error while creating a new referral: #{e.message}")
          render json: {
            'message': 'Error while creating a new record',
            'errors': [e.message]
          }, status: :internal_server_error
        end
      end
    
      def show
    
      end
    
      def update
    
      end
    
      def destroy
    
      end
      swagger_api :assign_recruiter do
        summary "Assign recruiter to referral record"
        notes "This create the association of the referral with the recruiter user"
        param :path, :id, :integer, :required, "referral id"
        param :path, :user_id, :integer, :required, "recruiter user id"
        response :no_content
        response :not_found, "Record not found"
        response :bad_request, "Bad Request"
        response :internal_server_error, "Error while assigning recruiter"
      end
      def assign_recruiter
        return render_invalid_recruiter_error(recruiter) unless recruiter.is_recruiter?

        current_referral.update!(recruiter: recruiter)
        render json: {}, except: [:created_at, :updated_at], status: :no_content
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error(e.message)
        render json: { message: 'Record not found', errors: [e.message] }, status: :not_found
      rescue StandardError => e
        Rails.logger.error("Error while assigning recruiter to referral #{e.message}")
        render json: {
          'message': 'Error while assigning recruiter',
          'errors': [e.message]
        }, status: :internal_server_error
      end
    
      private

      def referral_params
        params.permit([:referred_by, :full_name, :phone_number, :email, :linkedin_url, :cv_url,
                       :tech_stack, :ta_recruiter, :status, :comments, :active])
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

      def render_invalid_recruiter_error(user)
        error_message = "The provided User: #{user.id} is not a TA member"
        Rails.logger.error(error_message)
        render json: {
          message: 'Bad Request',
          errors: [error_message]
        }, status: :bad_request
      end

      def current_referral
        @current_referral ||= Referral.find(params[:id])
      end

      def recruiter
        @recruiter ||= User.find(params[:user_id])
      end
    end    
  end
end
