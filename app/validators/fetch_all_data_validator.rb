class FetchAllDataValidator < GoodNight::Validators::BaseValidator
    params do
        required(:user_id).filled(:integer)
        required(:sort_by).filled(:string)
        required(:sort_direction).filled(:string, included_in?: %w[asc desc])
    end
end
