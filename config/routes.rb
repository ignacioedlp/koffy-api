Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  
  # Devise routes for users with custom invitations controller
  # Usamos nuestro controlador personalizado para manejar invitaciones en formato JSON
  devise_for :users, controllers: {
    invitations: 'invitations'
  }
  
  # Custom authentication routes
  post 'auth/google', to: 'auth#google'
  post 'login', to: 'auth#login'
  delete 'logout', to: 'auth#logout'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
