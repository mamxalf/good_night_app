require 'rails_helper'

RSpec.describe SleepRecordRepository do
  describe '#find_by_id' do
    let(:repo) { described_class }

    context 'when sleep record exists' do
      let(:sleep_record) { create(:sleep_record) }

      it 'returns success with the sleep record' do
        result = repo.find_by_id(sleep_record.id)
        expect(result).to be_success
        expect(result.value!).to eq(sleep_record)
      end
    end

    context 'when sleep record does not exist' do
      it 'returns failure with error message' do
        result = repo.find_by_id(-1)
        expect(result).to be_failure
        expect(result.failure).to eq("SleepRecord not found")
      end
    end
  end

  describe '#find_by_user_id' do
    let(:user) { create(:user) }
    let(:repo) { described_class }

    context 'when user has sleep records' do
      let(:sleep_record) { create(:sleep_record, user: user) }

      it 'returns success with the sleep record' do
        result = repo.find_by_user_id(sleep_record.user_id)
        expect(result).to be_success
        expect(result.value!).to eq(sleep_record)
      end
    end

    context 'when user does not have sleep records' do
      it 'returns failure with error message' do
        result = repo.find_by_user_id(-1)
        expect(result).to be_failure
        expect(result.failure).to eq("SleepRecord not found")
      end
    end
  end

  describe '#clock_in' do
    let(:user) { create(:user) }
    let(:repo) { described_class }
    let(:frozen_time) { Time.zone.local(2024, 1, 1, 12, 0, 0) }

    context 'when creating a new sleep record' do
      it 'creates a new sleep record with clock_in time' do
        travel_to frozen_time do
          result = repo.clock_in(user: user)
          expect(result).to be_success
          sleep_record = result.value!

          expect(sleep_record).to be_a(SleepRecord)
          expect(sleep_record.clock_in).to eq(frozen_time)
          expect(sleep_record.clock_out).to be_nil
          expect(sleep_record.user).to eq(user)
          expect(sleep_record).to be_persisted
        end
      end
    end

    context 'when required attributes are missing' do
      it 'return failure with error message' do
        result = repo.clock_in(user: nil)
        expect(result).to be_failure
        expect(result.failure).to eq([ "User must exist" ])
      end
    end
  end

  describe '#clock_out' do
    let(:sleep_record) { create(:sleep_record) }
    let(:repo) { described_class }

    it 'updates the sleep record with clock_out time' do
      result = repo.clock_out(sleep_record: sleep_record)
      expect(result).to be_success
      expect(result.value!).to eq(sleep_record)
      expect(sleep_record.reload.clock_out).not_to be_nil
    end
  end

  describe '#find_active_by_user_id' do
    let(:user) { create(:user) }
    let(:repo) { described_class }

    context 'when a user has an active sleep record' do
      before do
        create(:sleep_record, user: user, clock_in: Time.current, clock_out: nil)
      end

      it 'returns success with the active sleep record' do
        result = repo.find_active_by_user_id(user.id)
        expect(result).to be_success
        active_record = result.value!
        expect(active_record).to be_present
        expect(active_record.user_id).to eq(user.id)
        expect(active_record.clock_out).to be_nil
      end
    end

    context 'when a user does not have an active sleep record' do
      before do
        create(:sleep_record, user: user, clock_in: 1.day.ago, clock_out: Time.current)
      end

      it 'returns failure with error message' do
        result = repo.find_active_by_user_id(user.id)
        expect(result).to be_failure
        expect(result.failure).to eq("SleepRecord not found")
      end
    end
  end
end
