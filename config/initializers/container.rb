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

  register "repositories.following_relationship" do
    FollowingRelationshipRepository
  end

  # Validators
  register "validators.user_clock_time" do
    UserClockTimeValidator.new
  end

  register "validators.fetch_all_data" do
    FetchAllDataValidator.new
  end

  register "validators.relationship" do
    RelationshipValidator.new
  end

  # Use Cases
  register "use_cases.user_fetch_sleep_record" do
    UserFetchSleepRecordUseCase.new(
      fetch_all_data_validator: Container["validators.fetch_all_data"],
      sleep_record_repository: Container["repositories.sleep_record"]
    )
  end

  register "use_cases.user_clock_in" do
    UserClockInUseCase.new(
      clock_time_validator: Container["validators.user_clock_time"],
      user_repository: Container["repositories.user"],
      sleep_record_repository: Container["repositories.sleep_record"]
    )
  end

  register "use_cases.user_clock_out" do
    UserClockOutUseCase.new(
      clock_time_validator: Container["validators.user_clock_time"],
      user_repository: Container["repositories.user"],
      sleep_record_repository: Container["repositories.sleep_record"]
    )
  end

  register "use_cases.user_follow" do
    UserFollowUseCase.new(
      relationship_validator: Container["validators.relationship"],
      user_repository: Container["repositories.user"],
      following_relationship_repository: Container["repositories.following_relationship"]
    )
  end

  register "use_cases.user_unfollow" do
    UserUnfollowUseCase.new(
      relationship_validator: Container["validators.relationship"],
      user_repository: Container["repositories.user"],
      following_relationship_repository: Container["repositories.following_relationship"]
    )
  end

  register "use_cases.user_fetch_following_sleep_record" do
    UserFetchFollowingSleepRecordUseCase.new(
      fetch_all_data_validator: Container["validators.fetch_all_data"],
      user_repository: Container["repositories.user"],
      sleep_record_repository: Container["repositories.sleep_record"]
    )
  end
end

# Set up auto-injection
Import = Dry::AutoInject(Container)
