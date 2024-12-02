require 'swagger_helper'

RSpec.describe "V1::Relationships", type: :request do
  include_context "container setup"

  path "/v1/relationships/follow" do
    post "Follow a user" do
      tags "Relationships"
      consumes "application/json"
      produces "application/json"
      parameter name: :relationship, in: :body, schema: {
        type: :object,
        properties: {
          follower_id: { type: :integer, description: "ID of the user" },
          followed_id: { type: :integer, description: "ID of the user" }
        },
        required: [ "follower_id", "followed_id" ]
      }

      response(201, "relationship created") do
        let(:user1) { create(:user) }
        let(:user2) { create(:user) }
        let(:relationship) do
          { follower_id: user1.id, followed_id: user2.id }
        end

        run_test! do |response|
          expect(response).to have_http_status(201)

          json = JSON.parse(response.body, symbolize_names: true)
          expect(json[:data]).to include(
            follower_id: user1.id,
            followed_id: user2.id
          )
          expect(json[:message]).to eq("Successfully followed")
          expect(json[:status]).to eq("success")
        end
      end

      response(404, "followed user not found") do
        let(:user1) { create(:user) }
        let(:user2) { create(:user) }
        let(:relationship) do
          { follower_id: user1.id, followed_id: -1 }
        end

        run_test! do |response|
          expect(response).to have_http_status(404)
          expect(response.body).to match("User not found")
        end
      end

      response(404, "follower user not found") do
        let(:user1) { create(:user) }
        let(:user2) { create(:user) }
        let(:relationship) do
          { follower_id: -1, followed_id: user2.id }
        end

        run_test! do |response|
          expect(response).to have_http_status(404)
          expect(response.body).to match("User not found")
        end
      end

      response(422, "relationship already exists") do
        let(:user1) { create(:user) }
        let(:user2) { create(:user) }
        let(:relationship) do
          { follower_id: user1.id, followed_id: user2.id }
        end

        before do
          create(:follow_relationship, follower: user1, followed: user2)
        end

        run_test! do |response|
          expect(response).to have_http_status(422)
          expect(response.body).to match("Relationship already exists")
        end
      end

      response(422, "users cannot follow themselves") do
        let(:user1) { create(:user) }
        let(:relationship) do
          { follower_id: user1.id, followed_id: user1.id }
        end

        run_test! do |response|
          expect(response).to have_http_status(422)
          expect(response.body).to match("Users cannot follow themselves")
        end
      end
    end
  end

  path "/v1/relationships/unfollow" do
    post "Unfollow a user" do
      tags "Relationships"
      consumes "application/json"
      produces "application/json"
      parameter name: :relationship, in: :body, schema: {
        type: :object,
        properties: {
          follower_id: { type: :integer, description: "ID of the user" },
          followed_id: { type: :integer, description: "ID of the user" }
        },
        required: [ "follower_id", "followed_id" ]
      }

      response(201, "successfully unfollowed") do
        let(:user1) { create(:user) }
        let(:user2) { create(:user) }
        let(:relationship) do
          { follower_id: user1.id, followed_id: user2.id }
        end

        before do
          create(:follow_relationship, follower: user1, followed: user2)
        end

        run_test! do |response|
          expect(response).to have_http_status(201)

          json = JSON.parse(response.body, symbolize_names: true)
          expect(json[:data]).to include(
            follower_id: user1.id,
            followed_id: user2.id
          )
          expect(json[:message]).to eq("Successfully unfollowed")
          expect(json[:status]).to eq("success")
        end
      end

      response(404, "followed user not found") do
        let(:user1) { create(:user) }
        let(:relationship) do
          { follower_id: user1.id, followed_id: -1 }
        end

        run_test! do |response|
          expect(response).to have_http_status(404)
          expect(response.body).to match("User not found")
        end
      end

      response(404, "follower user not found") do
        let(:user2) { create(:user) }
        let(:relationship) do
          { follower_id: -1, followed_id: user2.id }
        end

        run_test! do |response|
          expect(response).to have_http_status(404)
          expect(response.body).to match("User not found")
        end
      end

      response(404, "relationship not found") do
        let(:user1) { create(:user) }
        let(:user2) { create(:user) }
        let(:relationship) do
          { follower_id: user1.id, followed_id: user2.id }
        end

        run_test! do |response|
          expect(response).to have_http_status(404)
          expect(response.body).to match("Relationship not found")
        end
      end
    end
  end
end
