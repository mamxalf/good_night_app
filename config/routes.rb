Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  get "/ping", to: proc { [ 200, {}, [ "pong" ] ] }
  # v1 router
  namespace :v1 do
    resource :sleep_records, only: [] do
      post :clock_in, on: :collection
    end
  end
end
