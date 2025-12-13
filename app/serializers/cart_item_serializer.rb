class CartItemSerializer
  include JSONAPI::Serializer
  attributes :id, :quantity, :total_price
  belongs_to :coffee_variant
end
