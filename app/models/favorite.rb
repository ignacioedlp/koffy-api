class Favorite < ApplicationRecord
  include Ransackable

  # Associations
  belongs_to :user
  belongs_to :favoritable, polymorphic: true

  # Validations
  validates :user_id, presence: true
  validates :favoritable_id, presence: true
  validates :favoritable_type, presence: true
  validates :user_id, uniqueness: { scope: [ :favoritable_type, :favoritable_id ],
                                     message: "already has this item in favorites" }

  # Scopes
  scope :coffees, -> { where(favoritable_type: "Coffee") }
  scope :roasters, -> { where(favoritable_type: "Roaster") }
  scope :coffee_variants, -> { where(favoritable_type: "CoffeeVariant") }
end
