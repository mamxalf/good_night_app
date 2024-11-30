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
