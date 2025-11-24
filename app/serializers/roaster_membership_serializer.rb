class RoasterMembershipSerializer
  include JSONAPI::Serializer
  
  attributes :id, :role, :active, :salary, :currency, :salary_period
  
  attribute :formatted_salary do |membership|
    membership.formatted_salary
  end
  
  attribute :monthly_salary do |membership|
    membership.monthly_salary
  end
  
  attribute :annual_salary do |membership|
    membership.annual_salary
  end
  
  attribute :hourly_salary do |membership|
    membership.hourly_salary
  end
  
  attribute :joined_at do |membership|
    membership.created_at
  end

  attribute :user_id do |membership|
    membership.user.id
  end
  
  attribute :user_email do |membership|
    membership.user.email
  end
  
  attribute :user_name do |membership|
    membership.user.name
  end
end

