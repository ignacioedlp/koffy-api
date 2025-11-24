class CoffeeCategory < ApplicationRecord
  belongs_to :coffee
  belongs_to :category

  validates :coffee_id, uniqueness: { scope: :category_id,
                                       message: "already exists in this category" }
end
