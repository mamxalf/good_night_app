require "dry/monads"

class GoodNight::Repositories::BaseRepository
  extend Dry::Monads[:result]

  class << self
    protected

    def Success(value)
      Dry::Monads::Success(value)
    end

    def Failure(error)
      Dry::Monads::Failure(error)
    end

    def all(model_class, conditions: {}, order: nil, limit: nil, offset: nil, includes: [])
      scope = model_class.includes(includes) if includes.any?
      scope ||= model_class.all

      scope = scope.where(conditions) if conditions.any?
      scope = scope.order(order) if order.present?
      scope = scope.limit(limit) if limit
      scope = scope.offset(offset) if offset

      Success(scope)
    rescue ActiveRecord::StatementInvalid => e
      Failure("Invalid query parameters: #{e.message}")
    rescue StandardError => e
      Failure("An error occurred while fetching records: #{e.message}")
    end

    def find_by(model_class, conditions)
      record = model_class.find_by(conditions)
      return Failure("#{model_class.name} not found") if record.nil?
      Success(record)
    end

    def create(model_class, attributes)
      record = model_class.new(attributes)
      return Failure(record.errors.full_messages) unless record.save
      Success(record)
    end

    def update(record, attributes)
      return Failure("#{record.class.name} not found") if record.nil?
      return Failure(record.errors.full_messages) unless record.update(attributes)
      Success(record)
    end

    def delete(record)
      return Failure("#{record.class.name} not found") if record.nil?
      return Failure(record.errors.full_messages) unless record.destroy
      Success(record)
    end
  end
end
