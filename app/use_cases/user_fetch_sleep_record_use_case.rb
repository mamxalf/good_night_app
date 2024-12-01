class UserFetchSleepRecordUseCase < GoodNight::UseCases::BaseUseCase
    include Dry::Monads::Do.for(:call)

    def initialize(fetch_all_data_validator:, sleep_record_repository:)
        @fetch_all_data_validator = fetch_all_data_validator
        @sleep_record_repository = sleep_record_repository
    end

    def call(params)
        query = yield @fetch_all_data_validator.call(params)
        @sleep_record_repository.find_all_records(
          conditions: { user_id: query.user_id },
          sort_by: query["sort_by"], # query.sort_by
          sort_direction: query.sort_direction
        )
    end
end
