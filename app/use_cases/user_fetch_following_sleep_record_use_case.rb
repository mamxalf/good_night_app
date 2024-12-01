class UserFetchFollowingSleepRecordUseCase < GoodNight::UseCases::BaseUseCase
  include Dry::Monads[:result]
  include Dry::Monads::Do.for(:call)

  def initialize(fetch_all_data_validator:, user_repository:, sleep_record_repository:)
    @fetch_all_data_validator = fetch_all_data_validator
    @user_repository = user_repository
    @sleep_record_repository = sleep_record_repository
  end

  def call(params)
    query = yield @fetch_all_data_validator.call(params)
    user = yield @user_repository.find_by_condition(id: query.user_id)

    @sleep_record_repository.find_all_following_sleep_records(
      user: user,
      range: {
        amount: query.range_amount || 1,
        unit: query.range_unit || "week"
      },
      sort_by: query[:sort_by] || "duration", # query.sort_by
      order: query.sort_direction || "desc"
    )
  end
end
