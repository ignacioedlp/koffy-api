class BusinessHourSerializer
  include JSONAPI::Serializer

  attributes :id, :day_of_week, :is_closed, :created_at, :updated_at

  attribute :opens_at do |business_hour|
    business_hour.opens_at&.strftime("%H:%M")
  end

  attribute :closes_at do |business_hour|
    business_hour.closes_at&.strftime("%H:%M")
  end

  # Relationship with roaster
  attribute :roaster_id do |business_hour|
    business_hour.roaster_id
  end

  # Optional: include roaster information
  belongs_to :roaster
end
