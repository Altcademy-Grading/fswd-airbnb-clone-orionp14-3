class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :property
  has_many :charges

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :user, presence: true
  validates :property, presence: true

  before_validation :check_start_date_smaller_than_end_date
  # before_validation :check_availability

  private

  def check_start_date_smaller_than_end_date
    return unless start_date > end_date

    raise ArgumentError, 'start date cannot be larger than end date'
  end

  def check_availability
    overlapped_bookings = property.bookings.where('start_date < ? AND end_date > ? ', end_date, start_date)
    exact_booking = property.bookings.where('start_date = ? AND end_date = ? ', start_date, end_date)

    return unless overlapped_bookings.count.positive? || exact_booking.count.positive?

    raise ArgumentError, 'date range overlaps with other bookings'
  end

  def is_paid?
    self.charges.pluck(:complete).include?(true)
  end
end