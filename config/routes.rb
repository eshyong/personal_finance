Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"
  get "dashboard/index"

  get "home/welcome", to: "users#welcome"
  get "sign_up", to: "users#new", as: :sign_up
  post "sign_up", to: "users#create"

  get "confirmations/confirm_email/:confirmation_token", to: "confirmations#confirm_email", as: :confirm_email

  resources :financial_accounts, only: [:index, :show] do
    resources :transactions, only: [:index]
  end

  get "financial_accounts/:id/spending_summary", to: "financial_accounts#spending_summary", as: :spending_summary

  resources :spending_category_rules, only: [:index, :show, :create, :destroy]


  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  post "stripe/link_accounts", to: "stripe#link_accounts", as: :link_accounts
  post "stripe/webhooks"
end
