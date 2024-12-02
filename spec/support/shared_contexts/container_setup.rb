RSpec.shared_context "container setup" do
  before do
    # Reset container registrations before each test
    Container.instance_variable_set(:@_container, {})

    # Repositories
    Container.register("repositories.user") { UserRepository }
    Container.register("repositories.sleep_record") { SleepRecordRepository }
    Container.register("repositories.following_relationship") { FollowingRelationshipRepository }

    # Validators
    Container.register("validators.user_clock_time") { UserClockTimeValidator.new }
    Container.register("validators.fetch_all_data") { FetchAllDataValidator.new }
    Container.register("validators.relationship") { RelationshipValidator.new }

    # Use Cases
    Container.register("use_cases.user_fetch_sleep_record") do
      UserFetchSleepRecordUseCase.new(
        fetch_all_data_validator: Container["validators.fetch_all_data"],
        sleep_record_repository: Container["repositories.sleep_record"]
      )
    end

    Container.register("use_cases.user_clock_in") do
      UserClockInUseCase.new(
        clock_time_validator: Container["validators.user_clock_time"],
        user_repository: Container["repositories.user"],
        sleep_record_repository: Container["repositories.sleep_record"]
      )
    end

    Container.register("use_cases.user_clock_out") do
      UserClockOutUseCase.new(
        clock_time_validator: Container["validators.user_clock_time"],
        sleep_record_repository: Container["repositories.sleep_record"]
      )
    end

    Container.register("use_cases.user_follow") do
      UserFollowUseCase.new(
        relationship_validator: Container["validators.relationship"],
        user_repository: Container["repositories.user"],
        following_relationship_repository: Container["repositories.following_relationship"]
      )
    end

    Container.register("use_cases.user_unfollow") do
      UserUnfollowUseCase.new(
        relationship_validator: Container["validators.relationship"],
        user_repository: Container["repositories.user"],
        following_relationship_repository: Container["repositories.following_relationship"]
      )
    end
  end
end
