FactoryBot.define do
  factory :follow_relationship do
    association :follower, factory: :user
    association :followed, factory: :user
  end
end
