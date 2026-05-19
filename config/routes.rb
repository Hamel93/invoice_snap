Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home"

  get "/dashboard", to: "pages#dashboard"

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
