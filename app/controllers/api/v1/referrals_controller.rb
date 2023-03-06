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
        referrals = Referral.accessible_by(current_ability).where(active: true)
        referrals = referrals.map { |referral| map_referral(referral) }

        log_debug("Fetching all Referrals")
        render json: referrals, except: [:active, :created_at, :updated_at]
      end

      swagger_api :create do
        summary "Create a Referral"
        notes "This creates a new referral"
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
          new_referral = referral_params
          new_referral[:linkedin_url] = referral_params[:linkedin_url].delete(' ')
          new_referral[:referred_by] = @current_user.id
          new_referral[:active] = true

          referral = Referral.new(new_referral)
          if referral.save
            log_debug("Creating referral with email #{referral.email}")
            render json: referral, except: [:created_at, :updated_at], status: :created
          else
            log_error("Error while creating a new referral")
            render json: {
              'message': "Error while creating a new referral",
              'errors': referral.errors,
            }, status: :unprocessable_entity
          end
        rescue StandardError => e
          log_error("Error while creating a new referral: #{e.message}")
          render json: {
            'message': "Error while creating a new record",
            'errors': [e.message],
          }, status: :internal_server_error
        end
      end

      def show
        referral = Referral.find_by(id: params[:id], active: true)
        log_debug("Fetching referral with email #{referral.email}")

        render json: map_referral(referral), except: [:active, :created_at, :updated_at]
      end

      swagger_api :update do
        summary "Update a Referral"
        notes "This updates the referral by id"
        param :path, :id, :integer, :required, "referral id"
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
        response :no_content
        response :not_found, "Record not found"
        response :bad_request, "Bad Request"
        response :internal_server_error, "Error while assigning recruiter"
      end

      def update
        if referral_params[:status].present? && @current_user.role_id == 2
          log_error("Error updating referral with id #{referral_params[:id]}")
          return render json: { message: "Unauthorized" },status: 401
        end

        current_referral.update!(referral_params)

        log_debug("Updating referral with id #{referral_params[:id]}")
        render json: {}, status: :no_content
      rescue ActiveRecord::RecordInvalid => e
        log_error(e.message)
        render json: { message: "Bad Request", errors: [e.message] }, status: :bad_request
      rescue ActiveRecord::RecordNotFound => e
        log_error(e.message)
        render json: { message: "Record not found", errors: [e.message] }, status: :not_found
      rescue StandardError => e
        log_error("Error while updating a referral: #{e.message}")
        render json: {
          'message': "Error while updating record",
          'errors': [e.message],
        }, status: :internal_server_error
      end

      def destroy
        current_referral.update!(
          {
            active: false,
          }
        )
        log_debug("Deleting referral with email #{current_referral.email}")
        render json: {}, status: :no_content
      rescue ActiveRecord::RecordInvalid => e
        log_error(e.message)
        render json: { message: "Bad Request", errors: [e.message] }, status: :bad_request
      rescue ActiveRecord::RecordNotFound => e
        log_error(e.message)
        render json: { message: "Record not found", errors: [e.message] }, status: :not_found
      rescue StandardError => e
        log_error("Error while updating a referral: #{e.message}")
        render json: {
          'message': "Error while updating record",
          'errors': [e.message],
        }, status: :internal_server_error
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
        log_debug("Assign recruiter to referral with email #{current_referral.email}")
        render json: {}, except: [:created_at, :updated_at], status: :no_content
      rescue ActiveRecord::RecordNotFound => e
        log_error(e.message)
        render json: { message: "Record not found", errors: [e.message] }, status: :not_found
      rescue StandardError => e
        log_error("Error while assigning recruiter to referral #{e.message}")
        render json: {
          'message': "Error while assigning recruiter",
          'errors': [e.message],
        }, status: :internal_server_error
      end

      private

      def map_referral(referral)
        {
          comments: referral[:comments],
          cv_url: referral[:cv_url],
          email: referral[:email],
          full_name: referral[:full_name],
          id: referral[:id],
          linkedin_url: referral[:linkedin_url],
          phone_number: referral[:phone_number],
          referred_by: referral[:referred_by],
          signed_date: referral[:signed_date],
          status: referral[:status],
          ta_recruiter: referral[:ta_recruiter].nil? ? 0 : referral[:ta_recruiter],
          tech_stack: referral[:tech_stack],
          referred_by_name: referral.referrer.name,
        }
      end

      def referral_params
        params.permit([:referred_by, :full_name, :phone_number, :email, :linkedin_url, :cv_url,
                       :tech_stack, :ta_recruiter, :status, :comments, :active])
      end

      def invalid_params_error
        unless params[:id].match? /\A\d+\z/
          message = "ID is not a numeric value"
          log_error(message)
          render json: {
            'message': "Invalid parameter",
            'errors': [message],
          }, status: :unprocessable_entity
        end
      end

      def render_invalid_recruiter_error(user)
        error_message = "The provided User: #{user.id} is not a TA member"
        log_error(error_message)
        render json: {
          message: "Bad Request",
          errors: [error_message],
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
