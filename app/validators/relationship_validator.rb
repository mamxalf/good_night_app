
class RelationshipValidator < GoodNight::Validators::BaseValidator
    params do
      required(:follower_id).filled(:integer)
      required(:followed_id).filled(:integer)
    end
end
