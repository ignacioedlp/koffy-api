class RoasterMembership < ApplicationRecord
  # Include Ransackable concern for ActiveAdmin search functionality
  include Ransackable

  # Associations
  belongs_to :user
  belongs_to :roaster

  # Declare attribute types for enums (required in Rails 7.2+)
  attribute :role, :string
  attribute :salary_period, :string

  # Enum for roles
  # Using string enum to make it database-readable
  enum :role, {
    member: "member",      # Basic member - can view roaster info
    barista: "barista",    # Barista - can manage inventory and production
    manager: "manager",    # Manager - can manage operations and team
    owner: "owner"         # Owner - full control over the roaster
  }, validate: true

  # Enum for salary periods
  enum :salary_period, {
    hourly: "hourly",       # Per hour
    daily: "daily",         # Per day
    weekly: "weekly",       # Per week
    biweekly: "biweekly",   # Every two weeks (quincenal)
    monthly: "monthly",     # Per month (default)
    annual: "annual"        # Per year
  }, validate: true

  # Validations
  validates :user_id, uniqueness: {
    scope: :roaster_id,
    message: "already has a membership in this roaster"
  }

  # Salary validations
  validates :salary, numericality: {
    greater_than_or_equal_to: 0,
    allow_nil: true
  }
  validates :currency, presence: true, inclusion: {
    in: %w[USD EUR COP ARS MXN CLP PEN],
    message: "%{value} is not a supported currency"
  }
  validates :salary_period, presence: true

  # Only one owner per roaster
  validate :only_one_owner_per_roaster, if: :owner?

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :owners, -> { where(role: "owner") }
  scope :managers, -> { where(role: "manager") }
  scope :baristas, -> { where(role: "barista") }
  scope :members, -> { where(role: "member") }

  # Callbacks
  before_validation :set_default_role, on: :create

  # Instance methods
  def can_manage?
    owner? || manager?
  end

  def can_edit?
    owner? || manager? || barista?
  end

  def can_view?
    active?
  end

  # Deactivate membership instead of destroying
  def deactivate!
    update(active: false)
  end

  def activate!
    update(active: true)
  end

  # Salary helper methods
  def formatted_salary
    return "Not set" if salary.nil?

    period_label = salary_period_label
    "#{currency_symbol}#{salary.round(2)} #{period_label}"
  end

  def currency_symbol
    symbols = {
      "USD" => "$",
      "EUR" => "€",
      "COP" => "$",
      "ARS" => "$",
      "MXN" => "$",
      "CLP" => "$",
      "PEN" => "S/"
    }
    symbols[currency] || currency
  end

  def salary_period_label
    labels = {
      "hourly" => "per hour",
      "daily" => "per day",
      "weekly" => "per week",
      "biweekly" => "biweekly",
      "monthly" => "per month",
      "annual" => "per year"
    }
    labels[salary_period] || salary_period
  end

  # Convert any salary period to monthly equivalent
  def monthly_salary
    return nil if salary.nil?

    case salary_period
    when "hourly"
      salary * 160  # Assuming 160 hours/month (40 hours/week * 4 weeks)
    when "daily"
      salary * 22   # Assuming 22 working days/month
    when "weekly"
      salary * 4.33 # Average weeks per month
    when "biweekly"
      salary * 2.16 # 26 biweekly periods / 12 months
    when "monthly"
      salary
    when "annual"
      salary / 12
    else
      salary
    end
  end

  # Convert any salary period to annual equivalent
  def annual_salary
    return nil if salary.nil?

    monthly_salary * 12
  end

  # Convert any salary period to hourly equivalent
  def hourly_salary
    return nil if salary.nil?

    case salary_period
    when "hourly"
      salary
    when "daily"
      salary / 8    # Assuming 8 hour work day
    when "weekly"
      salary / 40   # Assuming 40 hour work week
    when "biweekly"
      salary / 80   # 40 hours * 2 weeks
    when "monthly"
      salary / 160  # Assuming 160 hours/month
    when "annual"
      salary / 2080 # 52 weeks * 40 hours
    else
      salary / 160
    end
  end

  def has_salary?
    salary.present? && salary > 0
  end

  private

  def set_default_role
    self.role ||= "member"
  end

  def only_one_owner_per_roaster
    existing_owner = roaster.roaster_memberships
                            .owners
                            .where.not(id: id)
                            .exists?

    if existing_owner
      errors.add(:role, "roaster already has an owner")
    end
  end
end
