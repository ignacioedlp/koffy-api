class Coffee < ApplicationRecord
  include Ransackable

  belongs_to :roaster

  has_many :coffee_variants, dependent: :destroy

  has_many :coffee_categories, dependent: :destroy

  has_many_attached :images

  has_many :categories, through: :coffee_categories

  has_many :favorites, as: :favoritable, dependent: :destroy

  validates :name, presence: true, length: { minimum: 3, maximum: 100 }

  validates :slug, presence: true, uniqueness: true

  validates :description, length: { maximum: 1000 }, allow_blank: true

  before_validation :generate_slug, if: -> { name.present? && (slug.blank? || name_changed?) }

  validates :origin_country, length: { maximum: 100 }, allow_blank: true

  validates :varietal, length: { maximum: 100 }, allow_blank: true

  validates :process_method, length: { maximum: 50 }, allow_blank: true

  validates :roast_level, length: { maximum: 50 }, allow_blank: true

  validates :flavor_notes, length: { maximum: 500 }, allow_blank: true

  validates :is_active, inclusion: { in: [ true, false ] }

  # Custom validation to limit images to maximum 3
  validate :validate_images_count

  def validate_images_count
    if images.attached? && images.count > 3
      errors.add(:images, "can't have more than 3 images")
    end
  end

  scope :active, -> { where(coffees: { is_active: true }) }

  scope :inactive, -> { where(coffees: { is_active: false }) }

  scope :featured, -> { where(coffees: { featured: true }) }

  scope :featured_active, -> { featured.active }

  scope :by_name, -> { order("coffees.name": :asc) }

  scope :recent, -> { order("coffees.created_at": :desc) }

  scope :from_country, ->(country) { where(origin_country: country) }

  scope :roast_level_filter, ->(level) { where(roast_level: level) }

  scope :process_method_filter, ->(method) { where(process_method: method) }

  scope :in_category, ->(category_id) { joins(:categories).where(categories: { id: category_id }) }

  scope :from_roaster_slug, ->(slug) { joins(:roaster).where(roasters: { slug: slug }) }

  def in_stock?
    coffee_variants.sum(:stock) > 0
  end

  def min_price
    coffee_variants.minimum(:price)
  end

  def max_price
    coffee_variants.maximum(:price)
  end

  def total_stock
    coffee_variants.sum(:stock)
  end

  def add_to_category(category)
    categories << category unless categories.include?(category)
  end

  def remove_from_category(category)
    categories.delete(category)
  end

  def category_names
    categories.pluck(:name).join(", ")
  end

  def toggle_featured!
    update(featured: !featured)
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
    while Coffee.where(slug: slug).where.not(id: id).exists?
      self.slug = "#{base_slug}-#{counter}"
      counter += 1
    end
  end
end
