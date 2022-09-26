class Swagger::Docs::Config
  def self.transform_path(path, api_version)
    # Make a distinction between the APIs and API documentation paths.
    puts path
    "#{path}"
  end
end
class Swagger::Docs::Config
  def self.base_application; Rails.application end
end
Swagger::Docs::Config.base_api_controller = ActionController::API
Swagger::Docs::Config.register_apis({
  "1.0" => {
    # the extension used for the API
    # :api_extension_type => :xml,
    # the output location where your .json files are written to
    :api_file_path => "public",
    # the URL base path to your API
    :base_path => "https://pure-caverns-73223.herokuapp.com/",
    # :base_path => "http://localhost:3005",
    # if you want to delete all .json files at each generation
    :clean_directory => true,
    # add custom attributes to api-docs
    :attributes => {
      :info => {
        "swagger": "2.0",
        "title" => "Referral System API",
        "description" => "This is a sample description.",
      }
    }
  }
})