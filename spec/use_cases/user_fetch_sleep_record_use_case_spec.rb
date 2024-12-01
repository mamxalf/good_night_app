require 'rails_helper'

RSpec.describe UserFetchSleepRecordUseCase do
  let(:validator) { FetchAllDataValidator.new }
  let(:repository) { SleepRecordRepository }
  let(:use_case) { described_class.new(fetch_all_data_validator: validator, sleep_record_repository: repository) }
  let(:user) { create(:user) }

  describe '#call' do
    context 'with valid params' do
      let(:params) do
        {
          user_id: user.id,
          sort_by: 'created_at',
          sort_direction: 'desc'
        }
      end

      let!(:sleep_records) do
        [
          create(:sleep_record, user: user, created_at: 1.day.ago),
          create(:sleep_record, user: user, created_at: 2.days.ago)
        ]
      end

      it 'returns success with sorted sleep records' do
        result = use_case.call(params)

        expect(result).to be_success
        expect(result.value!).to eq(sleep_records)
        expect(result.value!.first.created_at).to be > result.value!.last.created_at
      end

      it 'sorts records in ascending order when specified' do
        params[:sort_direction] = 'asc'
        result = use_case.call(params)

        expect(result).to be_success
        expect(result.value!.first.created_at).to be < result.value!.last.created_at
      end

      it 'sorts by different columns when specified' do
        params[:sort_by] = 'clock_in'
        result = use_case.call(params)

        expect(result).to be_success
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { user_id: nil, sort_by: '', sort_direction: 'invalid' } }

      it 'returns failure when params are invalid' do
        result = use_case.call(invalid_params)

        expect(result).to be_failure
        expect(result.failure).to eq({ user_id: [ "must be filled" ], sort_by: [ "must be filled" ],
sort_direction: [ "must be one of: asc, desc" ] })
      end
    end

    context 'with non-existent user' do
      let(:params) do
        {
          user_id: 999999,
          sort_by: 'created_at',
          sort_direction: 'desc'
        }
      end

      it 'returns an empty result set' do
        result = use_case.call(params)

        expect(result).to be_success
        expect(result.value!).to be_empty
      end
    end
  end
end
