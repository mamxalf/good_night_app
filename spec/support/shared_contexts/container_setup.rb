RSpec.shared_context "container setup" do
  before do
    # Reset container registrations before each test
    Container.instance_variable_set(:@_container, {})

    # Re-register dependencies
    Container.register("repositories.user") { UserRepository }
    Container.register("repositories.sleep_record") { SleepRecordRepository }
    Container.register("validators.user_clock_time") { UserClockTimeValidator.new }
    Container.register("use_cases.user_clock_in") do
      UserClockInUseCase.new(
        clock_time_validator: Container["validators.user_clock_time"],
        user_repository: Container["repositories.user"],
        sleep_record_repository: Container["repositories.sleep_record"]
      )
    end
  end
end
