class Roaster < ApplicationRecord
  # Include Ransackable concern for ActiveAdmin search functionality
  include Ransackable
  
  # Associations
  # A roaster has many memberships (the join table)
  has_many :roaster_memberships, dependent: :destroy
  
  # A roaster has many users through memberships
  has_many :users, through: :roaster_memberships
  
  # A roaster has many coffees (products)
  has_many :coffees, dependent: :destroy
  
  # A roaster has many custom categories
  has_many :categories, dependent: :destroy
  
  has_one_attached :logo
  
  # Validations
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :location, length: { maximum: 200 }, allow_blank: true
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :average_rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_blank: true
  validates :delivery_available, inclusion: { in: [true, false] }
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_name, -> { order(name: :asc) }
  
  # Instance methods to get users by role
  def owners
    users.joins(:roaster_memberships)
         .where(roaster_memberships: { roaster_id: id, role: 'owner' })
  end
  
  def managers
    users.joins(:roaster_memberships)
         .where(roaster_memberships: { roaster_id: id, role: 'manager' })
  end
  
  def baristas
    users.joins(:roaster_memberships)
         .where(roaster_memberships: { roaster_id: id, role: 'barista' })
  end
  
  def members
    users.joins(:roaster_memberships)
         .where(roaster_memberships: { roaster_id: id, role: 'member' })
  end
  
  # Get all active members of this roaster
  def active_members
    users.joins(:roaster_memberships)
         .where(roaster_memberships: { roaster_id: id, active: true })
  end
  
  # Check if a user is a member of this roaster
  def has_member?(user)
    roaster_memberships.exists?(user: user, active: true)
  end
  
  # Get featured coffees for this roaster
  def featured_coffees
    coffees.featured_active
  end
  
  # Get active categories ordered by position
  def active_categories
    categories.active.by_position
  end
  
  # Get coffees by category
  def coffees_by_category(category)
    coffees.active.in_category(category.id)
  end
  
  # Count of active coffees
  def active_coffees_count
    coffees.active.count
  end
  
  # Count of featured coffees
  def featured_coffees_count
    coffees.featured_active.count
  end
end
