module Api
  module V1
    class ReferralsController < ApplicationController

      def index
        render json: Referral.where(active: true), except: [:active, :created_at, :updated_at]
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
    
      private
    
      def referral_params
        params.permit([:referred_by, :full_name, :phone_number, :email, :linkedin_url, :cv_url, :tech_stack, :ta_recruiter, :status, :comments])
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
    end    
  end
end
