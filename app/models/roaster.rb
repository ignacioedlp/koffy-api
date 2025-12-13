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

  # A roaster has many orders (as a seller)
  has_many :orders, dependent: :destroy

  # A roaster has many reviews (reviews from users)
  has_many :reviews, dependent: :destroy

  # A roaster has business hours (opening/closing times)
  has_many :business_hours, dependent: :destroy

  # Nested attributes for business hours
  accepts_nested_attributes_for :business_hours, allow_destroy: true

  # A roaster has many favorites
  has_many :favorites, as: :favoritable, dependent: :destroy

  has_one_attached :logo
  has_one_attached :image

  # Validations
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :slug, presence: true, uniqueness: true
  validates :location, length: { maximum: 200 }, allow_blank: true

  before_validation :generate_slug, if: -> { name.present? && (slug.blank? || name_changed?) }
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :average_rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_blank: true
  validates :delivery_available, inclusion: { in: [ true, false ] }

  # Callbacks
  after_create :create_default_business_hours

  def to_param
    slug
  end

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_name, -> { order(name: :asc) }

  # Instance methods to get users by role
  def owners
    users.joins(:roaster_memberships)
         .where(roaster_memberships: { roaster_id: id, role: "owner" })
  end

  def managers
    users.joins(:roaster_memberships)
         .where(roaster_memberships: { roaster_id: id, role: "manager" })
  end

  def baristas
    users.joins(:roaster_memberships)
         .where(roaster_memberships: { roaster_id: id, role: "barista" })
  end

  def members
    users.joins(:roaster_memberships)
         .where(roaster_memberships: { roaster_id: id, role: "member" })
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

  def favorited_by?(user)
    return false unless user
    favorites.where(user: user)
  end

  private

  def generate_slug
    base_slug = name.parameterize
    self.slug = base_slug
    counter = 1
    while Roaster.where(slug: slug).where.not(id: id).exists?
      self.slug = "#{base_slug}-#{counter}"
      counter += 1
    end
  end

  def create_default_business_hours
    # Create business hours for all 7 days of the week
    # Default: Monday to Friday 9:00-18:00, weekends closed
    # Only one time slot per day by default
    BusinessHour.day_of_weeks.keys.each do |day|
      business_hours.create!(
        day_of_week: day,
        is_closed: [ "saturday", "sunday" ].include?(day),
        opens_at: [ "saturday", "sunday" ].include?(day) ? nil : "09:00",
        closes_at: [ "saturday", "sunday" ].include?(day) ? nil : "18:00"
      )
    end
  end
end
