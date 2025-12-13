class BusinessHour < ApplicationRecord
  belongs_to :roaster

  # Enum for days of the week (0 = Sunday, 6 = Saturday)
  enum day_of_week: {
    sunday: 0,
    monday: 1,
    tuesday: 2,
    wednesday: 3,
    thursday: 4,
    friday: 5,
    saturday: 6
  }

  # Validations
  validates :day_of_week, presence: true
  validates :is_closed, inclusion: { in: [ true, false ] }

  # If not closed, opening and closing times are required
  validates :opens_at, presence: true, unless: :is_closed?
  validates :closes_at, presence: true, unless: :is_closed?

  # Validate that closes_at is after opens_at
  validate :closing_time_after_opening_time, unless: :is_closed?

  # Validate that time slots don't overlap for the same day
  validate :no_overlapping_hours, unless: :is_closed?

  # Scopes
  scope :for_day, ->(day) { where(day_of_week: day) }
  scope :open_days, -> { where(is_closed: false) }
  scope :closed_days, -> { where(is_closed: true) }
  scope :ordered_by_day, -> { order(:day_of_week, :opens_at) }

  def self.day_of_weeks
    {
      "sunday" => 0,
      "monday" => 1,
      "tuesday" => 2,
      "wednesday" => 3,
      "thursday" => 4,
      "friday" => 5,
      "saturday" => 6
    }
  end

  private

  def closing_time_after_opening_time
    return unless opens_at && closes_at

    if closes_at <= opens_at
      errors.add(:closes_at, "must be after opening time")
    end
  end


  def no_overlapping_hours
    return unless roaster && opens_at && closes_at

    # Find other business hours for the same roaster and day
    overlapping = roaster.business_hours
                        .where(day_of_week: day_of_week, is_closed: false)

    # Exclude current record if it's persisted
    overlapping = overlapping.where.not(id: id) if persisted?

    overlapping.each do |other|
      next unless other.opens_at && other.closes_at
      next if other.marked_for_destruction?

      # Check if current time range overlaps with other time range
      if opens_at < other.closes_at && closes_at > other.opens_at
        errors.add(:base, "Time slot overlaps with another business hour for this day")
        break
      end
    end
  end
end
