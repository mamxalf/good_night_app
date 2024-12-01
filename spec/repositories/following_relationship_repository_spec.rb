require "rails_helper"

RSpec.describe FollowingRelationshipRepository do
  let(:repo) { described_class }

  describe ".find_by_condition" do
    let(:follower) { create(:user) }
    let(:followed) { create(:user) }
    let!(:relationship) { create(:follow_relationship, follower: follower, followed: followed) }

    it "finds relationship by conditions" do
      result = repo.find_by_condition(follower: follower, followed: followed)
      expect(result).to be_success
      expect(result.value!).to eq(relationship)
    end

    it "returns nil when relationship doesn't exist" do
      result = repo.find_by_condition(follower: create(:user), followed: followed)
      expect(result).to be_failure
      expect(result.failure).to eq("FollowRelationship not found")
    end
  end

  describe ".create_relationship" do
    let(:follower) { create(:user) }
    let(:followed) { create(:user) }

    it "creates a new follow relationship" do
      expect {
        repo.create_relationship(follower: follower, followed: followed)
      }.to change(FollowRelationship, :count).by(1)

      relationship = FollowRelationship.last
      expect(relationship.follower).to eq(follower)
      expect(relationship.followed).to eq(followed)
    end
  end

  describe ".delete_relationship" do
    let(:follower) { create(:user) }
    let(:followed) { create(:user) }
    let!(:relationship) { create(:follow_relationship, follower: follower, followed: followed) }

    it "deletes an existing relationship" do
      expect {
        repo.delete_relationship(relationship)
      }.to change(FollowRelationship, :count).by(-1)
    end
  end
end
