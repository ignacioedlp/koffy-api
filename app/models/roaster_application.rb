class RoasterApplication < ApplicationRecord
  include Ransackable

  validates :email, presence: true, uniqueness: true
  validates :comment, length: { maximum: 500 }, allow_blank: true
  validates :roaster_name, presence: true, length: { maximum: 100 }
  validates :phone_number, length: { maximum: 20 }, allow_blank: true
  validates :full_name, presence: true, length: { maximum: 100 }
  validates :website_url, length: { maximum: 200 }, allow_blank: true

  enum type_of_business: {
    specialist: "Roaster specialist",
    cafe: "Cafe",
    retailer: "Distributor/Retailer",
    partnership: "Partnership",
    other: "Other"
  }
end
