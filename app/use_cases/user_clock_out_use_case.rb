class UserClockOutUseCase < GoodNight::UseCases::BaseUseCase
    include Dry::Monads::Do.for(:call)

    def initialize(clock_time_validator:, sleep_record_repository:)
      @clock_time_validator = clock_time_validator
      @sleep_record_repository = sleep_record_repository
    end

    def call(params)
      query = yield @clock_time_validator.call(params)
      sleep_record = yield @sleep_record_repository.find_by_condition(user_id: query.user_id, clock_out: nil)
      @sleep_record_repository.clock_out(sleep_record: sleep_record)
    end
end
