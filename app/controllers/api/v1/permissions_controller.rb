module Api
    module V1
        class PermissionsController < ApplicationController
            before_action :authenticate_user!

            def index
                permission_list = case @current_user.role_id
                when 1
                    [
                        {
                            id: 11,
                            label: "Manage Referrals"
                        },
                        {
                            id: 12,
                            label: "Manage Roles"
                        },
                        {
                            id: 13,
                            label: "Manage Users"
                        },
                    ]
                when 2
                    [
                        {
                            id: 21,
                            label: "View your Referrals"
                        },
                        {
                            id: 22,
                            label: "Edit your Referrals"
                        },
                        {
                            id: 23,
                            label: "Create Referral"
                        },
                    ]
                when 3
                    [
                        {
                            id: 31,
                            label: "View all Referrals"
                        },
                        {
                            id: 32,
                            label: "Edit all Referrals"
                        },
                        {
                            id: 33,
                            label: "Assign recruiter"
                        },
                    ]
                end
                log_debug("Fetching all permissions")
                render json: {permissions: permission_list}, status: 200
            end

            def show
                permission_list = case User.find(params[:id]).role_id
                when 1
                    [
                        {
                            id: 11,
                            label: "Manage Referrals"
                        },
                        {
                            id: 12,
                            label: "Manage Roles"
                        },
                        {
                            id: 13,
                            label: "Manage Users"
                        },
                    ]
                when 2
                    [
                        {
                            id: 21,
                            label: "View your Referrals"
                        },
                        {
                            id: 22,
                            label: "Edit your Referrals"
                        },
                        {
                            id: 23,
                            label: "Create Referral"
                        },
                    ]
                when 3
                    [
                        {
                            id: 31,
                            label: "View all Referrals"
                        },
                        {
                            id: 32,
                            label: "Edit all Referrals"
                        },
                        {
                            id: 33,
                            label: "Assign recruiter"
                        },
                    ]
                end
                log_debug("Fetching permission list for user with id #{params[:id]}")
                render json: {permissions: permission_list}, status: 200
            end
        end
    end
end