class UserClockTimeValidator < GoodNight::Validators::BaseValidator
  params do
    required(:user_id).filled(:integer)
  end
end
