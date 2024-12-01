require "hashie"
require "dry/validation"
require "dry/monads"

class GoodNight::Validators::BaseValidator < Dry::Validation::Contract
  include Dry::Monads[:result]

  def call(...)
    result = super
    return Failure(result.errors.to_h) unless result.success?

    Success(Hashie::Mash.new(result.to_h))
  end
end
