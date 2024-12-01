class SleepRecordRepository < GoodNight::Repositories::BaseRepository
  def self.find_by_condition(conditions)
    find_by(SleepRecord, conditions)
  end

  def self.clock_in(user:)
    create(SleepRecord, { user: user, clock_in: Time.current })
  end

  def self.clock_out(sleep_record:)
    update(sleep_record, { clock_out: Time.current })
  end

  def self.find_all_records(conditions: {}, sort_by: "created_at", sort_direction: "desc", includes: [ :user ])
    all(
      SleepRecord,
      conditions: conditions,
      order: { sort_by.to_sym => sort_direction.to_sym },
      includes: includes
    )
  end
end
