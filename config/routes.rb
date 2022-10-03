Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  match '*all', controller: 'application', action: 'cors_preflight_check', via: [:options]

  get '/api-docs' => redirect('/api/index.html?url=/api/v1/users.json')
  # Defines the root path route ("/")
  #get '/v1/', to: "welcome#index"

  get 'v1/greetings', to: 'welcome#index'
  post 'v1/greetings/:id', to: 'welcome#create'

  # Azure Oauth Callbacks URLs
  get "/auth" => "auth#index"
  get "/auth/:provider/callback" => "auth#callback"

  namespace :api do
    namespace :v1 do
      resources :users
      get "user/authorize" => "users#authorize"
      resources :referrals
      resources :roles, only: [:create, :index]
      patch 'referrals/:id/ta/:user_id', to: 'referrals#assign_recruiter', as: :referral_ta_assign
    end
  end
end
