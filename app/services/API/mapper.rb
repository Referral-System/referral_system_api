# frozen_string_literal: true

module API
  module Mapper
    class << self
      # @param message [String]
      # @param subject [String]
      # @param to_recipients [Array]
      # @param cc_recipients [Array]
      # @return [Hash{Symbol->Object}]
      def email(message, subject, to_recipients, cc_recipients)
        {
          message: {
            subject: subject,
            body: {
              contentType: "HTML",
              content: message
            },
            toRecipients: to_recipients,
            ccRecipients: cc_recipients
          }
        }
      end

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
