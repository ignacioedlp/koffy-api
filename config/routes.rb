Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  
  # Devise routes for users with custom invitations controller
  devise_for :users, controllers: {
    invitations: 'invitations'
  }
  
  # Custom authentication routes
  post 'auth/google', to: 'auth#google'
  post 'login', to: 'auth#login'
  delete 'logout', to: 'auth#logout'
  
  # Roasters routes
  resources :roasters do
    resources :members, only: [:index, :create, :update, :destroy], controller: 'roaster_members'
    resources :coffees, only: [:create, :update, :destroy] do
      resources :variants, only: [:create], controller: 'coffee_variants'
    end
    resources :categories, only: [:index, :show, :create, :update, :destroy]
  end
  
  # Coffees routes (public index and show only)
  resources :coffees, only: [:index, :show]

  # Orders routes (authenticated users only)
  resources :orders, only: [:index, :show, :create, :update] do
    collection do
      post 'scan_qr', to: 'orders#scan_qr'
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
