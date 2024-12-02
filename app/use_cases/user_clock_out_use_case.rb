class UserClockOutUseCase < GoodNight::UseCases::BaseUseCase
    include Dry::Monads::Do.for(:call)

    def initialize(clock_time_validator:, user_repository:, sleep_record_repository:)
      @clock_time_validator = clock_time_validator
      @user_repository = user_repository
      @sleep_record_repository = sleep_record_repository
    end

    def call(params)
      query = yield @clock_time_validator.call(params)
      user = yield @user_repository.find_by_condition(id: query.user_id)
      sleep_record = yield @sleep_record_repository.find_by_condition(user_id: user.id, clock_out: nil)
      @sleep_record_repository.clock_out(sleep_record: sleep_record)
    end
end
