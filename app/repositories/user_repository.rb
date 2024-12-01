class UserRepository < GoodNight::Repositories::BaseRepository
    def self.find_by_condition(conditions)
        find_by(User, conditions)
    end
end
