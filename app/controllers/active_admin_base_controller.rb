# Base controller for ActiveAdmin
# This allows ActiveAdmin to work with sessions and cookies
# while keeping the rest of the API as ActionController::API
class ActiveAdminBaseController < ActionController::Base
  # Prevent CSRF attacks for ActiveAdmin pages
  protect_from_forgery with: :exception
end

