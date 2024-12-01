require "dry/container"
require "dry/auto_inject"

class Container
  extend Dry::Container::Mixin

  # Repositories
  register "repositories.user" do
    UserRepository
  end

  register "repositories.sleep_record" do
    SleepRecordRepository
  end

  # Validators
  register "validators.user_clock_time" do
    UserClockTimeValidator.new
  end

  # Use Cases
  register "use_cases.user_clock_in" do
    UserClockInUseCase.new(
      clock_time_validator: Container["validators.user_clock_time"],
      user_repository: Container["repositories.user"],
      sleep_record_repository: Container["repositories.sleep_record"]
    )
  end
end

# Set up auto-injection
Import = Dry::AutoInject(Container)
