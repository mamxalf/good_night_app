class User < ApplicationRecord
  validates :name, presence: true

  has_many :sleep_records, dependent: :destroy
  has_many :follow_relationships, foreign_key: :follower_id
  has_many :followers_relationships, class_name: "FollowRelationship", foreign_key: :followed_id
  has_many :following, through: :follow_relationships, source: :followed
  has_many :followers, through: :followers_relationships, source: :follower
end
