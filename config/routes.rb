Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Current-month dashboard.
  root "overview#show"
  get "months/:year/:month", to: "overview#show", as: :month
  get "years/:year", to: "years#show", as: :year

  # Each user has a single household.
  resource :household, only: %i[new create show] do
    resources :invitations, only: :create
  end
  get "join/:token", to: "invitations#accept", as: :accept_invitation

  resources :categories
  resources :expenses
  resources :settlements, only: %i[create update]
end
