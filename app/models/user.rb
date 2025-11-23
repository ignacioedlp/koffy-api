class User < ApplicationRecord
  # Include Ransackable concern for ActiveAdmin search functionality
  include Ransackable
  
  # Include default devise modules. Others available are:
  # :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :lockable,
         :confirmable, :jwt_authenticatable, 
         jwt_revocation_strategy: JwtDenylist,
         lock_strategy: :failed_attempts, 
         unlock_strategy: :both

  # Validations
  validates :email, presence: true, uniqueness: true

  # Class method to find or create user from Google OAuth
  def self.from_google(email:, uid:, name:)
    user = User.find_by(email: email)
    
    if user
      # Update user with Google info if not already set
      user.update(provider: 'google', uid: uid, name: name) if user.provider.nil?
      user
    else
      # Create new user from Google OAuth
      # Google users are auto-confirmed since Google already verified their email
      User.create!(
        email: email,
        provider: 'google',
        uid: uid,
        name: name,
        password: Devise.friendly_token[0, 20],  # Generate random password
        confirmed_at: Time.now  # Auto-confirm Google OAuth users
      )
    end
  end
end
