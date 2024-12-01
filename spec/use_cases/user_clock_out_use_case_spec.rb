require 'rails_helper'

RSpec.describe UserClockOutUseCase do
  include Dry::Monads[:result]

  let(:sleep_record_repository) { class_double(SleepRecordRepository) }
  let(:validator) { instance_double(UserClockTimeValidator) }
  let(:use_case) do
    described_class.new(
      clock_time_validator: validator,
      sleep_record_repository: sleep_record_repository
    )
  end

  describe '#call' do
    let(:params) { Hashie::Mash.new(user_id: 1) }
    let(:user) { build(:user, id: 1) }
    let(:sleep_record) { build(:sleep_record, user: user, clock_out: nil) }

    before do
      allow(sleep_record_repository).to receive(:find_by_condition)
      allow(sleep_record_repository).to receive(:clock_out)
    end

    context 'when validation succeeds' do
      before do
        allow(validator).to receive(:call).with(params).and_return(Success(params))
      end

      context 'when user has an active sleep record' do
        before do
          allow(sleep_record_repository).to receive(:find_by_condition)
            .with(user_id: params.user_id, clock_out: nil)
            .and_return(Success(sleep_record))

          allow(sleep_record_repository).to receive(:clock_out)
            .with(sleep_record: sleep_record)
            .and_return(Success(sleep_record))
        end

        it 'updates the sleep record with clock_out time' do
          result = use_case.call(params)

          expect(result).to be_success
          expect(result.value!).to eq(sleep_record)
          expect(sleep_record_repository).to have_received(:clock_out).with(sleep_record: sleep_record)
        end
      end

      context 'when user has no active sleep record' do
        before do
          allow(sleep_record_repository).to receive(:find_by_condition)
            .with(user_id: params.user_id, clock_out: nil)
            .and_return(Failure("SleepRecord not found"))
        end

        it 'returns failure with error message' do
          result = use_case.call(params)

          expect(result).to be_failure
          expect(result.failure).to eq("SleepRecord not found")
          expect(sleep_record_repository).not_to have_received(:clock_out)
        end
      end
    end

    context 'when validation fails' do
      before do
        allow(validator).to receive(:call)
          .with(params)
          .and_return(Failure([ "User ID must be present" ]))
      end

      it 'returns validation errors' do
        result = use_case.call(params)

        expect(result).to be_failure
        expect(result.failure).to eq([ "User ID must be present" ])
        expect(sleep_record_repository).not_to have_received(:find_by_condition)
      end
    end

    context 'when clock_out fails' do
      before do
        allow(validator).to receive(:call).with(params).and_return(Success(params))
        allow(sleep_record_repository).to receive(:find_by_condition)
          .with(user_id: params.user_id, clock_out: nil)
          .and_return(Success(sleep_record))
        allow(sleep_record_repository).to receive(:clock_out)
          .with(sleep_record: sleep_record)
          .and_return(Failure("Failed to update sleep record"))
      end

      it 'returns failure with error message' do
        result = use_case.call(params)

        expect(result).to be_failure
        expect(result.failure).to eq("Failed to update sleep record")
      end
    end
  end
end
