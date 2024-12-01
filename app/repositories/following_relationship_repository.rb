class FollowingRelationshipRepository < GoodNight::Repositories::BaseRepository
  def self.find_by_condition(conditions)
    find_by(FollowRelationship, conditions)
  end

  def self.create_relationship(follower:, followed:)
    create(FollowRelationship, { follower: follower, followed: followed })
  end

  def self.delete_relationship(relationship)
    delete(relationship)
  end
end
