class User < ApplicationRecord
  validates :name, presence: true

  has_many :sleep_records, dependent: :destroy
end
