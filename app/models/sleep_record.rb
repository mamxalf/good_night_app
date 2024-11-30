class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :clock_in, presence: true
  validate :clock_out_after_clock_in

  private

  def clock_out_after_clock_in
    return if clock_in.blank? || clock_out.blank?

    if clock_out <= clock_in
      errors.add(:clock_out, "must be after clock in time")
    end
  end
end
