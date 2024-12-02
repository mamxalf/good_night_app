class V1::RelationshipsController < ApplicationController
    include DryMatcherHandler

    def initialize
      super
      @user_follow_relationship = Container["use_cases.user_follow"]
      @user_unfollow_relationship = Container["use_cases.user_unfollow"]
      @user_fetch_following_sleep_record = Container["use_cases.user_fetch_following_sleep_record"]
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

    def unfollow
        result = @user_unfollow_relationship.call(params.permit(:follower_id, :followed_id).to_h)
        handle_result(result) do |response|
          render json: {
            data: response,
            message: "Successfully unfollowed",
            status: "success"
          }, status: :created
        end
    end

    def sleeping_records
        result = @user_fetch_following_sleep_record.call(params.permit(:user_id, :range_amount, :range_unit, :sort_by,
          :sort_direction).to_h)
        handle_result(result) do |response|
          render json: {
            data: response,
            message: "Successfully fetched sleep records",
            status: "success"
          }, status: :ok
        end
    end
end
