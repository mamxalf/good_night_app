require 'rails_helper'

RSpec.describe SleepRecordRepository do
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
      it 'raises an error when user is not provided' do
        result = repo.clock_in(user: nil)
        expect(result).to be_failure
        expect(result.failure).to eq([ "User must exist" ])
      end
    end
  end
end
