class V1::RelationshipsController < ApplicationController
    include DryMatcherHandler

    def initialize
      super
      @user_follow_relationship = Container["use_cases.user_follow"]
    end

    def follow
        result = @user_follow_relationship.call(params.permit(:follower_id, :followed_id).to_h)
        handle_result(result) do |response|
          render json: {
            data: response,
            message: "Successfully followed",
            status: "success"
          }, status: :created
        end
    end
end
