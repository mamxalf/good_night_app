class UserClockInUseCase < GoodNight::UseCases::BaseUseCase
  include Dry::Monads::Do.for(:call)

  def initialize(clock_in_validator:, user_repository:, sleep_record_repository:)
    @clock_in_validator = clock_in_validator
    @user_repository = user_repository
    @sleep_record_repository = sleep_record_repository
  end

  def call(params)
    clock_in_data = yield @clock_in_validator.call(params)
    user = yield @user_repository.find_by_id(clock_in_data.user_id)
    user_active = @sleep_record_repository.find_active_by_user_id(user.id)
    return Failure("User already has an active sleep record") if user_active.success?

    @sleep_record_repository.clock_in(user: user)
  end
end
