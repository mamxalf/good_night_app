require 'rails_helper'

RSpec.describe UserFetchFollowingSleepRecordUseCase do
  include Dry::Monads[:result]

  let(:fetch_all_data_validator) { instance_double(FetchAllDataValidator) }
  let(:user_repository) { class_double(UserRepository) }
  let(:sleep_record_repository) { class_double(SleepRecordRepository) }
  let(:use_case) do
    described_class.new(
      fetch_all_data_validator: fetch_all_data_validator,
      user_repository: user_repository,
      sleep_record_repository: sleep_record_repository
    )
  end

  describe '#call' do
    let(:user) { build(:user, id: 1) }
    let(:following_user) { build(:user, id: 2) }
    let(:sleep_records) do
      [
        build(:sleep_record, user: following_user, clock_in: 2.days.ago, clock_out: 1.day.ago),
        build(:sleep_record, user: following_user, clock_in: 4.days.ago, clock_out: 3.days.ago)
      ]
    end

    let(:base_params) { Hashie::Mash.new(user_id: user.id) }

    context 'when fetching records with default parameters' do
      let(:params) { base_params }
      let(:validated_params) do
        Hashie::Mash.new(
          user_id: user.id,
          range_amount: nil,
          range_unit: nil,
          sort_by: nil,
          sort_direction: nil
        )
      end

      before do
        allow(fetch_all_data_validator).to receive(:call)
          .with(params)
          .and_return(Success(validated_params))
        allow(user_repository).to receive(:find_by_condition)
          .with(id: user.id)
          .and_return(Success(user))
        allow(sleep_record_repository).to receive(:find_all_following_sleep_records)
          .with(
            user: user,
            range: { amount: 1, unit: "week" },
            sort_by: "duration",
            order: "desc"
          )
          .and_return(Success(sleep_records))
      end

      it 'returns sleep records with default settings' do
        result = use_case.call(params)
        expect(result).to be_success
        expect(result.value!).to eq(sleep_records)
      end
    end

    context 'when fetching records with custom parameters' do
      let(:params) {
 base_params.merge(range_amount: 2, range_unit: "month", sort_by: "clock_in", sort_direction: "asc") }
      let(:validated_params) do
        Hashie::Mash.new(
          user_id: user.id,
          range_amount: 2,
          range_unit: "month",
          sort_by: "clock_in",
          sort_direction: "asc"
        )
      end

      before do
        allow(fetch_all_data_validator).to receive(:call)
          .with(params)
          .and_return(Success(validated_params))
        allow(user_repository).to receive(:find_by_condition)
          .with(id: user.id)
          .and_return(Success(user))
        allow(sleep_record_repository).to receive(:find_all_following_sleep_records)
          .with(
            user: user,
            range: { amount: 2, unit: "month" },
            sort_by: "clock_in",
            order: "asc"
          )
          .and_return(Success(sleep_records))
      end

      it 'returns sleep records with custom settings' do
        result = use_case.call(params)
        expect(result).to be_success
        expect(result.value!).to eq(sleep_records)
      end
    end

    context 'when validation fails' do
      let(:error_message) { 'Invalid parameters' }

      before do
        allow(fetch_all_data_validator).to receive(:call)
          .with(base_params)
          .and_return(Failure(error_message))
      end

      it 'returns failure with error message' do
        result = use_case.call(base_params)
        expect(result).to be_failure
        expect(result.failure).to eq(error_message)
      end
    end

    context 'when user is not found' do
      let(:error_message) { 'User not found' }
      let(:validated_params) { Hashie::Mash.new(user_id: user.id) }

      before do
        allow(fetch_all_data_validator).to receive(:call)
          .with(base_params)
          .and_return(Success(validated_params))
        allow(user_repository).to receive(:find_by_condition)
          .with(id: user.id)
          .and_return(Failure(error_message))
      end

      it 'returns failure with error message' do
        result = use_case.call(base_params)
        expect(result).to be_failure
        expect(result.failure).to eq(error_message)
      end
    end
  end
end
