Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home"

  get "/dashboard",     to: "pages#dashboard"
  get "/profile",       to: "pages#profile"
  get "/notifications", to: "pages#notifications"
  get "/statistics",    to: "pages#statistics"

  resources :invoices do
    collection do
      get :search
      get :camera
      post :scan
    end
  end

  resources :folders
  resources :reminders
end
