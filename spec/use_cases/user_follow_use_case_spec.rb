require 'rails_helper'

RSpec.describe UserFollowUseCase do
  include Dry::Monads[:result]

  let(:relationship_validator) { instance_double(RelationshipValidator) }
  let(:user_repository) { class_double(UserRepository) }
  let(:following_relationship_repository) { class_double(FollowingRelationshipRepository) }
  let(:use_case) do
    described_class.new(
      relationship_validator: relationship_validator,
      user_repository: user_repository,
      following_relationship_repository: following_relationship_repository
    )
  end

  describe '#call' do
    let(:follower) { build(:user, id: 1) }
    let(:followed) { build(:user, id: 2) }
    let(:params) { Hashie::Mash.new(follower_id: follower.id, followed_id: followed.id) }

    before do
      allow(user_repository).to receive(:find_by_condition)
      allow(following_relationship_repository).to receive(:create_relationship)
    end

    context 'when validation succeeds' do
      before do
        allow(relationship_validator).to receive(:call).with(params).and_return(Success(params))
        allow(user_repository).to receive(:find_by_condition)
          .with(id: params.follower_id)
          .and_return(Success(follower))
        allow(user_repository).to receive(:find_by_condition)
          .with(id: params.followed_id)
          .and_return(Success(followed))
        allow(following_relationship_repository).to receive(:create_relationship)
          .with(follower: follower, followed: followed)
          .and_return(Success(build(:follow_relationship)))
      end

      it 'creates a follow relationship' do
        result = use_case.call(params)

        expect(result).to be_success
        expect(following_relationship_repository).to have_received(:create_relationship)
          .with(follower: follower, followed: followed)
      end
    end

    context 'when validation fails' do
      let(:error_message) { 'Invalid relationship parameters' }

      before do
        allow(relationship_validator).to receive(:call)
          .with(params)
          .and_return(Failure(error_message))
      end

      it 'returns failure with error message' do
        result = use_case.call(params)

        expect(result).to be_failure
        expect(result.failure).to eq(error_message)
      end
    end

    context 'when follower user is not found' do
      let(:error_message) { 'User not found' }

      before do
        allow(relationship_validator).to receive(:call).with(params).and_return(Success(params))
        allow(user_repository).to receive(:find_by_condition)
          .with(id: params.follower_id)
          .and_return(Failure(error_message))
      end

      it 'returns failure with error message' do
        result = use_case.call(params)

        expect(result).to be_failure
        expect(result.failure).to eq(error_message)
      end
    end

    context 'when followed user is not found' do
      let(:error_message) { 'User not found' }

      before do
        allow(relationship_validator).to receive(:call).with(params).and_return(Success(params))
        allow(user_repository).to receive(:find_by_condition)
          .with(id: params.follower_id)
          .and_return(Success(follower))
        allow(user_repository).to receive(:find_by_condition)
          .with(id: params.followed_id)
          .and_return(Failure(error_message))
      end

      it 'returns failure with error message' do
        result = use_case.call(params)

        expect(result).to be_failure
        expect(result.failure).to eq(error_message)
      end
    end

    context 'when creating relationship fails' do
      let(:error_message) { 'Failed to create relationship' }

      before do
        allow(relationship_validator).to receive(:call).with(params).and_return(Success(params))
        allow(user_repository).to receive(:find_by_condition)
          .with(id: params.follower_id)
          .and_return(Success(follower))
        allow(user_repository).to receive(:find_by_condition)
          .with(id: params.followed_id)
          .and_return(Success(followed))
        allow(following_relationship_repository).to receive(:create_relationship)
          .with(follower: follower, followed: followed)
          .and_return(Failure(error_message))
      end

      it 'returns failure with error message' do
        result = use_case.call(params)

        expect(result).to be_failure
        expect(result.failure).to eq(error_message)
      end
    end
  end
end
