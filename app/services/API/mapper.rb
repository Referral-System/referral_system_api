# frozen_string_literal: true

module API
  module Mapper
    class << self
      NEW_REFERRAL_SUBJECT = "New Referral Notification"

      # @param message [String]
      # @return [Hash{Symbol->Object}]
      def email(message)
        {
          message: {
            subject: NEW_REFERRAL_SUBJECT,
            body: {
              contentType: "HTML",
              content: message
            },
            toRecipients: build_recipients(:notification_emails),
            ccRecipients: build_recipients(:cc_notification_emails)
          }
        }
      end

      private

      # @param key [Symbol]
      # @return [Array<Hash{Symbol->Object}>]
      def build_recipients(key)
        Rails.configuration.settings[key].each_with_object([]) do |email, result|
          result << {
            emailAddress: {
              address: email
            }
          }
        end
      end
    end
  end
end
