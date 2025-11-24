class Category < ApplicationRecord
  include Ransackable

  belongs_to :roaster

  has_many :coffee_categories, dependent: :destroy
  has_many :coffees, through: :coffee_categories

  validates :name, presence: true, length: { minimum: 2, maximum: 50 }

  validates :name, uniqueness: { scope: :roaster_id,
                                  message: "already exists for this roaster",
                                  case_sensitive: false }

  validates :description, length: { maximum: 300 }, allow_blank: true

  validates :color, format: { with: /\A#[0-9A-F]{6}\z/i,
                              message: "must be a valid hex color code (e.g., #FF5733)" },
                    allow_blank: true

  validates :icon, length: { maximum: 50 }, allow_blank: true

  validates :is_active, inclusion: { in: [ true, false ] }

  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :active, -> { where(is_active: true) }

  scope :inactive, -> { where(is_active: false) }

  scope :by_position, -> { order(position: :asc) }

  scope :by_name, -> { order(name: :asc) }

  scope :recent, -> { order(created_at: :desc) }

  before_validation :set_default_position, on: :create, if: -> { position.nil? }

  def coffees_count
    coffees.count
  end

  def active_coffees_count
    coffees.active.count
  end

  def has_coffees?
    coffees.exists?
  end

  def full_name
    "#{roaster.name} - #{name}"
  end

  private

  def set_default_position
    max_position = roaster.categories.maximum(:position) || -1
    self.position = max_position + 1
  end
end
