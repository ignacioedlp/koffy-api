Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Devise routes for users with custom invitations controller
  devise_for :users, controllers: {
    invitations: "invitations"
  }

  # Custom authentication routes
  post "auth/google", to: "auth#google"
  post "login", to: "auth#login"
  delete "logout", to: "auth#logout"

  namespace :api do
    namespace :roaster do
      resources :categories, only: [ :index, :show, :create, :update, :destroy ]
      resources :members, only: [ :index, :create, :update, :destroy ], controller: "roaster_members"
      resources :reviews, only: [ :index ]
      resources :coffees, only: [ :index, :show, :create, :update, :destroy ] do
        resources :coffee_variants, only: [ :create, :update, :destroy ]
      end
      resources :orders, only: [ :index, :show ] do
        collection do
          post "scan_qr", to: "orders#scan_qr"
        end
      end
      resources :subscriptions, only: [ :index ]
    end

    # Coffees routes (public index and show only)
    resources :coffees, only: [ :index, :show ], param: :slug
    resources :roasters, only: [ :index, :show ], param: :slug

    # Cart routes
    resource :cart, only: [ :show ]
    resources :cart_items, only: [ :create, :update, :destroy ]

    # Orders routes (authenticated users only)
    resources :orders, only: [ :index, :show, :create, :update ]

    # User profile routes
    resource :me, only: [ :show ], controller: "me"

    resources :reviews

    # Subscriptions routes
    resources :subscriptions, only: [ :index, :create, :update, :destroy ]

    # Roaster Applications routes
    resources :roaster_applications, only: [ :create ]

    # Favorites routes
    resources :favorites, only: [ :index, :create, :destroy ] do
      collection do
        delete "remove", to: "favorites#remove"
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
