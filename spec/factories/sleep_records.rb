FactoryBot.define do
  factory :sleep_record do
    association :user
    clock_in { 1.day.ago }
    clock_out { Time.current }
  end
end
