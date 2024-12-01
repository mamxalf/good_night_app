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

  def self.find_all_following_sleep_records(user:, range: { amount: 1, unit: "week" },
    sort_by: "duration", order: "desc")
    validate_and_normalize_params!(range, sort_by, order)
    records = fetch_following_records(user, range)
    sorted_records = sort_records(records, sort_by, order)
    Success(sorted_records)
  end

  private_class_method def self.validate_and_normalize_params!(range, sort_by, order)
    valid_units = %w[day days week weeks month months year years]
    valid_sort_fields = %w[duration clock_in clock_out]
    valid_orders = %w[asc desc]

    normalized_unit = range[:unit].to_s.singularize
    range[:unit] = valid_units.include?(normalized_unit) ? normalized_unit : "week"
    range[:amount] = 1 unless range[:amount].is_a?(Integer) && range[:amount] > 0
    sort_by.replace("duration") unless valid_sort_fields.include?(sort_by)
    order.replace("desc") unless valid_orders.include?(order)
  end

  private_class_method def self.fetch_following_records(user, range)
    SleepRecord.joins(user: :followers)
      .where(users: { id: user.following.pluck(:id) })
      .where("clock_in >= ?", range[:amount].send(range[:unit]).ago)
  end

  private_class_method def self.sort_records(records, sort_by, order)
    sorted = case sort_by
    when "duration"
      records.sort_by { |r| r.clock_out - r.clock_in }
    when "clock_in"
      records.sort_by(&:clock_in)
    when "clock_out"
      records.sort_by(&:clock_out)
    end

    order == "desc" ? sorted.reverse : sorted
  end
end
