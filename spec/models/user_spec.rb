require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'associations' do
    it { should have_many(:sleep_records).dependent(:destroy) }
    it { should have_many(:follow_relationships).with_foreign_key(:follower_id) }
    it { should have_many(:followers_relationships).class_name('FollowRelationship').with_foreign_key(:followed_id) }
    it { should have_many(:following).through(:follow_relationships).source(:followed) }
    it { should have_many(:followers).through(:followers_relationships).source(:follower) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'is invalid without a name' do
      user = build(:user, name: nil)
      expect(user).not_to be_valid
    end
  end

  describe 'attributes' do
    it 'has an id and name' do
      user = create(:user)
      expect(user.id).not_to be_nil
      expect(user.name).not_to be_nil
    end
  end

  describe 'following relationships' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    it 'can follow another user' do
      create(:follow_relationship, follower: user, followed: other_user)
      expect(user.following).to include(other_user)
      expect(other_user.followers).to include(user)
    end
  end
end
