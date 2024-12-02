require 'rails_helper'

RSpec.describe FollowRelationship, type: :model do
  let(:follower) { create(:user) }
  let(:followed) { create(:user) }
  let(:follow_relationship) { build(:follow_relationship, follower: follower, followed: followed) }

  describe 'validations' do
    it { should validate_presence_of(:follower_id) }
    it { should validate_presence_of(:followed_id) }
    it 'has a unique follower_id scoped to followed_id' do
      follow_relationship.save
      duplicate_follow_relationship = build(:follow_relationship, follower: follower, followed: followed)
      expect(duplicate_follow_relationship).not_to be_valid
      expect(duplicate_follow_relationship.errors[:follower_id]).to include("Relationship already exists")
    end

    it 'is valid with valid attributes' do
      expect(follow_relationship).to be_valid
    end

    it 'is not valid when user tries to follow themselves' do
      self_follow = build(:follow_relationship, follower: follower, followed: follower)
      expect(self_follow).not_to be_valid
      expect(self_follow.errors[:base]).to include("Users cannot follow themselves")
    end
  end

  describe 'associations' do
    it { should belong_to(:follower).class_name('User') }
    it { should belong_to(:followed).class_name('User') }
  end
end
