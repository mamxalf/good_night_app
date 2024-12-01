class UserUnfollowUseCase < GoodNight::UseCases::BaseUseCase
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
        @relationship = yield @following_relationship_repository.find_by_condition(follower: follower,
          followed: followed)
        @following_relationship_repository.delete_relationship(@relationship)
    end
end
