require "rails_helper"

RSpec.describe UserRepository do
  describe "#find_by_condition" do
    let(:repo) { described_class }

    context "when user exists" do
      let(:user) { create(:user) }

      it "returns Success monad with user" do
        result = repo.find_by_condition(id: user.id)
        expect(result).to be_success
        expect(result.value!).to eq(user)
      end
    end

    context "when user does not exist" do
      it "returns Failure monad with error message" do
        result = repo.find_by_condition(id: -1)
        expect(result).to be_failure
        expect(result.failure).to eq("User not found")
      end
    end
  end
end
