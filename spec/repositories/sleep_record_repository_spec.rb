require 'rails_helper'

RSpec.describe SleepRecordRepository do
  describe '#find_by_condition' do
    let(:repo) { described_class }

    it 'finds a sleep record by id' do
      sleep_record = create(:sleep_record)
      result = repo.find_by_condition(id: sleep_record.id)
      expect(result).to be_success
      expect(result.value!).to eq(sleep_record)
    end

    it 'finds a sleep record by user_id' do
      sleep_record = create(:sleep_record)
      result = repo.find_by_condition(user_id: sleep_record.user_id)
      expect(result).to be_success
      expect(result.value!).to eq(sleep_record)
    end

    it 'returns failure with error message' do
      result = repo.find_by_condition(id: -1)
      expect(result).to be_failure
      expect(result.failure).to eq("SleepRecord not found")
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

  describe '#find_all_records' do
    let(:repo) { described_class }

    it 'finds all sleep records' do
      sleep_record = create(:sleep_record)
      result = repo.find_all_records
      expect(result).to be_success
      expect(result.value!).to be_a(Array)
      expect(result.value!).to include(sleep_record)
    end

    it 'finds all sleep records with conditions' do
      sleep_record = create(:sleep_record)
      result = repo.find_all_records(conditions: { id: sleep_record.id })
      expect(result).to be_success
      expect(result.value!).to include(sleep_record)
    end

    it 'finds all sleep records with order' do
      5.times do |i|
        create(:sleep_record, created_at: Time.zone.now + i.days)
      end
      result = repo.find_all_records(sort_by: "created_at", sort_direction: "desc")
      expect(result).to be_success
      expect(result.success.map(&:created_at)).to eq(result.success.map(&:created_at).sort.reverse)
    end

    it 'finds all sleep records with empty result' do
      result = repo.find_all_records
      expect(result).to be_success
      expect(result.value!).to be_empty
    end
  end
end
