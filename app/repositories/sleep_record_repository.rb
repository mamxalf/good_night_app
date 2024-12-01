class SleepRecordRepository < GoodNight::Repositories::BaseRepository
  def self.find_by_id(id)
    find_by(SleepRecord, id: id)
  end

  def self.find_by_user_id(user_id)
    find_by(SleepRecord, user_id: user_id)
  end

  def self.clock_in(user:)
    create(SleepRecord, { user: user, clock_in: Time.current })
  end

  def self.find_active_by_user_id(user_id)
    find_by(SleepRecord, user_id: user_id, clock_out: nil)
  end
end
