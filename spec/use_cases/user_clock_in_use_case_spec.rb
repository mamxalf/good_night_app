require 'rails_helper'

RSpec.describe UserClockInUseCase do
  include Dry::Monads[:result]

  let(:user_repository) { class_double(UserRepository) }
  let(:sleep_record_repository) { class_double(SleepRecordRepository) }
  let(:validator) { instance_double(UserClockInValidator) }
  let(:use_case) do
    described_class.new(
      clock_in_validator: validator,
      user_repository: user_repository,
      sleep_record_repository: sleep_record_repository
    )
  end

  describe '#call' do
    let(:params) { Hashie::Mash.new(user_id: 1) }
    let(:user) { build(:user, id: 1) }

    before do
      allow(sleep_record_repository).to receive(:find_active_by_user_id)
      allow(user_repository).to receive(:find_by_id)
      allow(sleep_record_repository).to receive(:clock_in)
    end

    context 'when validation succeeds' do
      before do
        allow(validator).to receive(:call).with(params).and_return(Success(params))
        allow(user_repository).to receive(:find_by_id).with(params[:user_id]).and_return(Success(user))
      end

      context 'when user has no active sleep record' do
        let(:sleep_record) { build(:sleep_record, id: 1, user: user) }

        before do
          allow(sleep_record_repository).to receive(:find_active_by_user_id)
            .with(params[:user_id])
            .and_return(Failure("SleepRecord not found"))

          allow(sleep_record_repository).to receive(:clock_in)
            .with(user: user)
            .and_return(Success(sleep_record))
        end

        it 'creates a new sleep record' do
          result = use_case.call(params)

          expect(result).to be_success
          expect(result.value!).to eq(sleep_record)
          expect(sleep_record_repository).to have_received(:clock_in).with(user: user)
        end
      end

      context 'when user already has an active sleep record' do
        let(:active_sleep_record) { build(:sleep_record, user: user) }

        before do
          allow(sleep_record_repository).to receive(:find_active_by_user_id)
            .with(params[:user_id])
            .and_return(Success(active_sleep_record))
        end

        it 'returns failure with error message' do
          result = use_case.call(params)

          expect(result).to be_failure
          expect(result.failure).to eq("User already has an active sleep record")
          expect(sleep_record_repository).not_to have_received(:clock_in)
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
        expect(user_repository).not_to have_received(:find_by_id)
      end
    end

    context 'when user is not found' do
      before do
        allow(validator).to receive(:call).with(params).and_return(Success(params))
        allow(user_repository).to receive(:find_by_id)
          .with(params[:user_id])
          .and_return(Failure("User not found"))
      end

      it 'returns failure with error message' do
        result = use_case.call(params)

        expect(result).to be_failure
        expect(result.failure).to eq("User not found")
        expect(sleep_record_repository).not_to have_received(:find_active_by_user_id)
      end
    end
  end
end
