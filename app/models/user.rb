class User < ApplicationRecord
  # Include Ransackable concern for ActiveAdmin search functionality
  include Ransackable
  
  # Include Roaster authorization methods
  include RoasterAuthorizable
  
  # Include default devise modules. Others available are:
  # :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :lockable,
         :confirmable, :jwt_authenticatable, 
         jwt_revocation_strategy: JwtDenylist,
         lock_strategy: :failed_attempts, 
         unlock_strategy: :both

  # Associations
  # A user has many orders (as a customer)
  has_many :orders, dependent: :destroy
  
  # Validations
  validates :email, presence: true, uniqueness: true
  validates :profile_picture_url, length: { maximum: 200 }, allow_blank: true
  validates :preferred_grind_method, length: { maximum: 50 }, allow_blank: true
  validates :preferred_roast_level, length: { maximum: 50 }, allow_blank: true
  validates :preferred_bag_size, length: { maximum: 20 }, allow_blank: true

  # Scopes
  # Scope to find users who are NOT members of any roaster (coffee lovers only)
  scope :coffee_lovers_only, -> { 
    left_outer_joins(:roaster_memberships)
      .where(roaster_memberships: { id: nil })
      .distinct 
  }
  
  # Scope to find users who ARE members of at least one roaster
  scope :roaster_members, -> { 
    joins(:roaster_memberships)
      .distinct 
  }

  # Instance method to check if user is a coffee lover (not a member of any roaster)
  # A coffee lover is a user who has no active roaster memberships
  def coffee_lover?
    active_roaster_memberships.empty?
  end

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
