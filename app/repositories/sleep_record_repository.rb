class SleepRecordRepository < GoodNight::Repositories::BaseRepository
  def self.clock_in(user:)
    create(SleepRecord, { user: user, clock_in: Time.current })
  end
end
