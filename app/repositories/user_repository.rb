class UserRepository < GoodNight::Repositories::BaseRepository
    def self.find_by_id(id)
        find_by(User, id: id)
    end
end
