require 'rails_helper'

RSpec.describe SleepRecord, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:clock_in) }
    it { should validate_presence_of(:clock_out) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      sleep_record = build(:sleep_record)
      expect(sleep_record).to be_valid
    end
  end

  describe 'time validations' do
    let(:user) { create(:user) }

    it 'is invalid if clock_out is before clock_in' do
      sleep_record = build(:sleep_record,
        clock_in: Time.current,
        clock_out: 1.hour.ago
      )
      expect(sleep_record).not_to be_valid
      expect(sleep_record.errors[:clock_out]).to include("must be after clock in time")
    end

    it 'is valid if clock_out is after clock_in' do
      sleep_record = build(:sleep_record,
        clock_in: 1.hour.ago,
        clock_out: Time.current
      )
      expect(sleep_record).to be_valid
    end
  end
end
