module DbLogger
  # @param msg [String]
  # @return [void]
  def log_debug(msg)
    create_log_entry(msg)
    Rails.logger.debug(msg)
  end

  # @param msg [String]
  # @return [void]
  def log_error(msg)
    create_log_entry(msg, true)
    Rails.logger.error(msg)
  end

  private

  # @param msg [String]
  # @param has_error [bool]
  # @return [void]
  def create_log_entry(msg, has_error = false)
    data = {
      view: controller_name,
      action: action_name,
      user_id: @current_user&.id,
      user_name: @current_user&.name,
      request_payload: params&.except(:controller, :action),
      message: msg,
      has_error: has_error
    }

    Log.create!(data)
  end
end
