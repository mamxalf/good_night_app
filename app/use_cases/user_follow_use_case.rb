class UserFollowUseCase < GoodNight::UseCases::BaseUseCase
    include Dry::Monads::Do.for(:call)

    def initialize(relationship_validator:, user_repository:, following_relationship_repository:)
        @relationship_validator = relationship_validator
        @user_repository = user_repository
        @following_relationship_repository = following_relationship_repository
    end
    def call(params)
        relationship_data = yield @relationship_validator.call(params)
        follower = yield @user_repository.find_by_condition(id: relationship_data.follower_id)
        followed = yield @user_repository.find_by_condition(id: relationship_data.followed_id)
        @following_relationship_repository.create_relationship(follower: follower, followed: followed)
    end
end
