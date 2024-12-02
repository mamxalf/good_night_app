require 'rails_helper'

RSpec.describe UserClockOutUseCase do
  include Dry::Monads[:result]

  let(:sleep_record_repository) { class_double(SleepRecordRepository) }
  let(:validator) { instance_double(UserClockTimeValidator) }
  let(:user_repository) { class_double(UserRepository) }
  let(:use_case) do
    described_class.new(
      clock_time_validator: validator,
      sleep_record_repository: sleep_record_repository,
      user_repository: user_repository
    )
  end

  describe '#call' do
    let(:params) { Hashie::Mash.new(user_id: 1) }
    let(:user) { build(:user, id: 1) }
    let(:sleep_record) { build(:sleep_record, user: user, clock_out: nil) }

    before do
      allow(user_repository).to receive(:find_by_condition)
      allow(sleep_record_repository).to receive(:find_by_condition)
      allow(sleep_record_repository).to receive(:clock_out)
    end

    context 'when validation succeeds' do
      before do
        allow(validator).to receive(:call).with(params).and_return(Success(params))
      end

      context 'when user exists' do
        before do
          allow(user_repository).to receive(:find_by_condition)
            .with(id: params.user_id)
            .and_return(Success(user))
        end

        context 'when user has an active sleep record' do
          before do
            allow(sleep_record_repository).to receive(:find_by_condition)
              .with(user_id: user.id, clock_out: nil)
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

        context 'when user does not have an active sleep record' do
          before do
            allow(sleep_record_repository).to receive(:find_by_condition)
              .with(user_id: user.id, clock_out: nil)
              .and_return(Failure(:sleep_record_not_found))
          end

          it 'returns a failure' do
            result = use_case.call(params)

            expect(result).to be_failure
            expect(result.failure).to eq(:sleep_record_not_found)
          end
        end
      end

      context 'when user does not exist' do
        before do
          allow(user_repository).to receive(:find_by_condition)
            .with(id: params.user_id)
            .and_return(Failure(:user_not_found))
        end

        it 'returns a failure' do
          result = use_case.call(params)

          expect(result).to be_failure
          expect(result.failure).to eq(:user_not_found)
        end
      end
    end

    context 'when validation fails' do
      before do
        allow(validator).to receive(:call)
          .with(params)
          .and_return(Failure(:invalid_params))
      end

      it 'returns a failure' do
        result = use_case.call(params)

        expect(result).to be_failure
        expect(result.failure).to eq(:invalid_params)
      end
    end
  end
end
