Rails.application.routes.draw do
  devise_for :users

  devise_scope :user do
    get "/logout", to: "devise/sessions#destroy"
  end

  get "/login", to: redirect("/users/sign_in")
  get "/sign_in", to: redirect("/users/sign_in")
  get "/signup", to: redirect("/users/sign_up")
  get "/sign_up", to: redirect("/users/sign_up")

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
  resources :chats, only: [:index, :show, :create, :destroy] do
    resources :messages, only: [:create]
  end
end
