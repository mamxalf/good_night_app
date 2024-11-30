require "dry/monads"
require "dry/matcher"

class GoodNight::UseCases::BaseUseCase
  include Dry::Monads[:result]

  def self.call(...)
    new(...).call
  end

  protected

  def Success(value)
    Dry::Monads::Success(value)
  end

  def Failure(error)
    Dry::Monads::Failure(error)
  end
end
