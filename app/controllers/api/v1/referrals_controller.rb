module Api
  module V1
    class ReferralsController < ApplicationController
      before_action :authenticate_user!
      load_and_authorize_resource

      NEW_REFERRAL_SUBJECT = "New Referral Notification"
      REFERRAL_ASSIGNED_SUBJECT = "New Referral Assigned"

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
        param :form, :tech_stack, :string, :optional, "Tech stack of referred used"
        param :form, :ta_recruiter, :integer, :optional, "Ta recruiter ID"
        param :form, :referral_status_id, :integer, :optional, "Status of referred used"
        param :form, :comments, :string, :optional, "Comments for referral"
        param :form, :active, :boolean, :optional, "Referral is active"
        response :created
        response :unprocessable_entity, "Error, the transaction has failed"
        response :internal_server_error, "Error while creating a new record"
      end

      def create
        begin
          new_referral = referral_params
          new_referral[:referral_status_id] ||= ReferralStatus.first.id
          new_referral[:linkedin_url] = referral_params[:linkedin_url].delete(' ')
          new_referral[:referred_by] = @current_user.id
          new_referral[:active] = true

          if params[:file]
            filename = upload_file(new_referral[:full_name], params[:file])
            if filename.nil?
              log_error("Error while creating a new referral: #{e.message}")
              render json: {
                'message': "Error while creating a new record",
                'errors': [e.message],
              }, status: :internal_server_error
            end

            new_referral[:cv_url] = filename
          end

          referral = Referral.new(new_referral)
          ActiveRecord::Base.transaction do
            referral.save!
            referral.referral_status_histories.new(referral_status_history_params(referral.referral_status_id)).save!
            send_new_referral_email(referral)
            log_debug("Creating referral with email #{referral.email}")

            render json: referral, except: [:created_at, :updated_at], status: :created
          end
        rescue ActiveRecord::RecordInvalid => e
          message = "Error, the transaction has failed, reason: #{e.message}"
          log_error(message)

          render json: { message: message, errors: referral&.errors }, status: :unprocessable_entity
        rescue StandardError => e
          message = "Error while creating a new referral: #{e.message}"
          log_error(message)

          render json: { message: message, errors: referral&.errors }, status: :internal_server_error
        end
      end

      def show
        referral = Referral.find_by(id: params[:id], active: true)

        unless referral
          log_error('Error, record not found')

          render json: { message: 'Record not found', errors: 'Record not found' }, status: :not_found
        else
          log_debug("Fetching referral with email #{referral.email}")

          render json: map_referral(referral), except: [:active, :created_at, :updated_at]
        end
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
        param :form, :referral_status_id, :integer, :optional, "Status of referred used"
        param :form, :comments, :string, :optional, "Comments for referral"
        param :form, :active, :boolean, :optional, "Referral is active"
        response :no_content
        response :not_found, "Record not found"
        response :bad_request, "Bad Request"
        response :internal_server_error, "Error while assigning recruiter"
      end

      def update
        if referral_params[:referral_status_id].present? && @current_user.role_id == 2
          log_error("Error updating referral with id #{referral_params[:id]}")

          return render json: { message: "Unauthorized" }, status: 401
        end

        if params[:file]
          filename = upload_file(referral_params[:full_name], params[:file], current_referral[:cv_url])
          if filename.nil?
            log_error("Error while updating a referral: #{e.message}")
            render json: {
              'message': "Error while updating a record",
              'errors': [e.message],
            }, status: :internal_server_error
          end

          referral_params[:cv_url] = filename
        end        

        ActiveRecord::Base.transaction do
          previous_status = current_referral.referral_status_id
          current_referral.update!(referral_params)

          if previous_status != referral_params[:referral_status_id]
            current_referral.referral_status_histories.new(referral_status_history_params(referral_params[:referral_status_id])).save!
          end

          log_debug("Updating referral with id #{referral_params[:id]}")
        end

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
        ActiveRecord::Base.transaction do
          current_referral.update!(
            {
              active: false
            }
          )
        end
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
        ActiveRecord::Base.transaction do
          current_referral.update!(recruiter: recruiter)
          send_referral_assigned_email(current_referral, recruiter)
        end
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

      swagger_api :download_cv do
        summary "Download referral cv"
        notes "Download referral cv from sharepoint"
        param :path, :id, :integer, :required, "referral id"
        response :no_content
        response :not_found, "Record not found"
        response :internal_server_error, "Error while downloading cv"
      end

      def download_cv
        result = client.download_file(current_referral.cv_url)
        log_debug("Download #{current_referral.email} cv")
        send_file(result, type: result.content_type, filename: current_referral.cv_url)
      rescue ActiveRecord::RecordNotFound => e
        log_error(e.message)
        render json: { message: "Record not found", errors: [e.message] }, status: :not_found
      rescue StandardError => e
        log_error("Error while downloading cv #{e.message}")
        render json: {
          'message': "Error while downloading cv",
          'errors': [e.message],
        }, status: :internal_server_error
      end

      private

      # @return [MicrosoftGraphClient]
      def client
        API::MicrosoftGraphClient.new(ReferralSystemEmailUser.first&.current_access_token)
      end

      # @param referral [Referral]
      # @return [void]
      def send_new_referral_email(referral)
        template = File.read('app/mailers/templates/new_referral.html.erb')
        message = template % new_referral_variables(referral)
        to_recipients = API::Mapper.build_recipients(:notification_emails)
        cc_recipients = API::Mapper.build_recipients(:cc_notification_emails)
        payload = API::Mapper.email(message, NEW_REFERRAL_SUBJECT, to_recipients, cc_recipients)
        client.send_mail(payload)
      end

      # @param referral [Referral]
      # @param recruiter [User]
      # @return [void]
      def send_referral_assigned_email(referral, recruiter)
        template = File.read('app/mailers/templates/referral_assigned.html.erb')
        message = template % new_referral_variables(referral)
        to_recipients = [{ emailAddress: { address: recruiter.email }}]
        cc_recipients = API::Mapper.build_recipients(:cc_notification_emails)
        payload = API::Mapper.email(message, REFERRAL_ASSIGNED_SUBJECT, to_recipients, cc_recipients)
        client.send_mail(payload)
      end

      # @param referral [Referral]
      # @return [Hash]
      def new_referral_variables(referral)
        {
          referral_id: referral.id,
          referral_name: referral.full_name,
          referral_contact: "#{referral.email} (#{referral.phone_number})",
          referral_date: referral.created_at.strftime("%Y-%m-%d"),
          referred_by: "#{referral.referrer.name} (#{referral.referrer.email})"
        }
      end

      # @param name [String]
      # @param file [File]
      # @return string
      def upload_file(name, file, filename = nil)
        original_name = file.original_filename.split(".").last
        filename ||= "#{String.new(name).gsub!(" ", "_")}-#{Time.now.to_date}-#{(rand*100).to_i}.#{original_name}"
        result = UploadFile.call(file: file, filename: filename)
        return if result.failure?

        filename
      end

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
          status: referral[:referral_status_id],
          ta_recruiter: referral[:ta_recruiter].nil? ? 0 : referral[:ta_recruiter],
          tech_stack: referral[:tech_stack],
          referred_by_name: referral.referrer.name,
        }
      end

      def referral_params
        params.permit([:referred_by, :full_name, :phone_number, :email, :linkedin_url,
                       :tech_stack, :ta_recruiter, :referral_status_id, :comments, :active])
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

      def referral_status_history_params(status)
        {
          referral_status_id: status,
          user_id: current_user.id
        }
      end
    end
  end
end
