require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'is invalid without a name' do
      user = build(:user, name: nil)
      expect(user).not_to be_valid
    end
  end

  describe 'attributes' do
    it 'has an id and name' do
      user = create(:user)
      expect(user.id).not_to be_nil
      expect(user.name).not_to be_nil
    end
  end
end
