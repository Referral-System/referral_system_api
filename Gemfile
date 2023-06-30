source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.3"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.3", ">= 7.0.3.1"

# Use mysql as the database for Active Record
gem "mysql2", "~> 0.5"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Permissions
gem "cancancan"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem "rack-cors"

gem "swagger-docs"
gem "faker", :git => "https://github.com/faker-ruby/faker.git", :branch => "master"

# JWT
gem "jwt"

# Faraday
gem "faraday", "~> 2.2"
gem "faraday-multipart", "~> 1.0"

# Interactor
gem "interactor-rails", "~> 2.0"

# Oauth
gem "omniauth"
gem "omniauth-azure-oauth2"

group :development, :test do
  gem "dotenv-rails"
  gem "pry-byebug"
  gem "factory_bot_rails"
  gem "rspec"
  gem "rspec_junit_formatter"
  gem "rails-controller-testing"
  gem "rspec-rails"
  gem "spring-commands-rspec"
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end
