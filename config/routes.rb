Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home"

  get "/dashboard", to: "pages#dashboard"
  get "/notifications", to: "pages#notifications"
  get "/profile", to: "pages#profile"

  resources :invoices do
    collection do
      get :search
      get :camera
      post :scan
    end
  end

  resources :folders
  resources :reminders

  resources :chats, only: [:index, :show, :create] do
    resources :messages, only: [:create]
  end
end
