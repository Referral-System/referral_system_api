# Upload file to sharepoint
class UploadFile
  include Interactor

  before do
    @file = context.file
    @filename = context.filename
    @client = API::MicrosoftGraphClient.new(ReferralSystemEmailUser.first&.current_access_token)
  end

  # context:
  #   file [File]
  #   filename [String]
  # @return [Interactor::Context]
  def call
    response = client.upload_file(file, filename)
    context.fail!(error: "Error uploading file") unless response.success?

    context.data = response.body
  end

  private

  attr_reader :file, :filename, :client
end
