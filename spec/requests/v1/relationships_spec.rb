require 'swagger_helper'

RSpec.describe "V1::Relationships", type: :request do
  include_context "container setup"
  include ActiveSupport::Testing::TimeHelpers

  path "/v1/relationships/follow" do
    post "Follow a user" do
      tags "Relationships"
      consumes "application/json"
      produces "application/json"
      parameter(
        name: :relationship,
        in: :body,
        schema: {
          type: :object,
          properties: {
            follower_id: { type: :integer, description: "ID of the user" },
            followed_id: { type: :integer, description: "ID of the user" }
          },
          required: [ "follower_id", "followed_id" ]
        }
      )

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
      parameter(
        name: :relationship,
        in: :body,
        schema: {
          type: :object,
          properties: {
            follower_id: { type: :integer, description: "ID of the user" },
            followed_id: { type: :integer, description: "ID of the user" }
          },
          required: [ "follower_id", "followed_id" ]
        }
      )

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

  path "/v1/relationships/sleeping_records" do
    get "Get following users' sleep records" do
      tags "Relationships"
      produces "application/json"
      parameter(
        name: :user_id,
        in: :query,
        schema: { type: :integer },
        required: true
      )
      parameter(
        name: :range_amount,
        in: :query,
        schema: { type: :integer },
        required: false,
        description: "Defaults to 1"
      )
      parameter(
        name: :range_unit,
        in: :query,
        schema: { type: :string, enum: [ 'days', 'weeks', 'months' ] },
        required: false,
        description: "Defaults to 'week'"
      )
      parameter(
        name: :sort_by,
        in: :query,
        schema: {
          type: :string,
          enum: [ 'created_at', 'clock_in', 'clock_out', 'duration' ]
        },
        required: true,
        description: "Sort records by created_at, clock_in, clock_out, or duration"
      )
      parameter(
        name: :sort_direction,
        in: :query,
        schema: { type: :string, enum: [ 'asc', 'desc' ] },
        required: true,
        description: "Sort direction ascending or descending"
      )

      response(200, "successfully fetched sleep records") do
        let(:user1) { create(:user) }
        let(:user2) { create(:user) }
        let(:user3) { create(:user) }
        let(:user_id) { user1.id }
        let(:range_amount) { 7 }
        let(:range_unit) { 'days' }
        let(:sort_by) { 'duration' }
        let(:sort_direction) { 'desc' }
        let(:base_time) { Time.zone.local(2024, 1, 1, 12, 0, 0) }

        before do
          travel_to base_time
          create(:follow_relationship, follower: user1, followed: user2)
          create(:follow_relationship, follower: user1, followed: user3)

          # Create sleep records for user2
          @record1 = create(:sleep_record, user: user2,
            clock_in: Time.current,
            clock_out: Time.current + 8.hours)

          # Create sleep records for user2 - next day
          travel 1.day
          @record2 = create(:sleep_record, user: user2,
            clock_in: Time.current,
            clock_out: Time.current + 7.hours)

          # Create sleep records for user3
          travel 1.day
          @record3 = create(:sleep_record, user: user3,
            clock_in: Time.current,
            clock_out: Time.current + 6.hours)

          travel 1.day
          @record4 = create(:sleep_record, user: user3,
            clock_in: Time.current,
            clock_out: Time.current + 9.hours)

          # Move to current time for the test
          travel 1.day
        end

        after { travel_back }

        run_test! do |response|
          expect(response).to have_http_status(200)

          json = JSON.parse(response.body, symbolize_names: true)
          expect(json[:message]).to eq("Successfully fetched sleep records")
          expect(json[:status]).to eq("success")
          expect(json[:data]).to be_an(Array)
          expect(json[:data].length).to eq(4)

          # Verify records are sorted by duration in descending order
          durations = json[:data].map do |record|
            (Time.parse(record[:clock_out]) - Time.parse(record[:clock_in])).to_i
          end
          expect(durations).to eq([ 9.hours.to_i, 8.hours.to_i, 7.hours.to_i, 6.hours.to_i ])
        end
      end

      response(200, "successfully fetched sleep records with created_at sorting") do
        let(:user1) { create(:user) }
        let(:user2) { create(:user) }
        let(:user_id) { user1.id }
        let(:sort_by) { 'created_at' }
        let(:sort_direction) { 'asc' }
        let(:base_time) { Time.zone.local(2024, 1, 1, 12, 0, 0) }

        before do
          travel_to base_time
          create(:follow_relationship, follower: user1, followed: user2)

          # Create records with different timestamps
          @record1 = create(:sleep_record, user: user2,
            clock_in: Time.current,
            clock_out: Time.current + 6.hours)

          travel 1.day
          @record2 = create(:sleep_record, user: user2,
            clock_in: Time.current,
            clock_out: Time.current + 8.hours)

          # Move to current time for the test
          travel 1.day
        end

        after { travel_back }

        run_test! do |response|
          expect(response).to have_http_status(200)

          json = JSON.parse(response.body, symbolize_names: true)
          expect(json[:data].length).to eq(2)

          # Verify records are sorted by created_at in ascending order
          created_ats = json[:data].map { |record| record[:created_at] }
          expect(created_ats).to eq([ @record1.created_at.iso8601(3), @record2.created_at.iso8601(3) ])
        end
      end

      response(404, "user not found") do
        let(:user_id) { -1 }
        let(:sort_by) { 'duration' }
        let(:sort_direction) { 'desc' }

        before do
          travel_to Time.zone.local(2024, 1, 1, 12, 0, 0)
        end

        after { travel_back }

        run_test! do |response|
          expect(response).to have_http_status(404)
          expect(response.body).to match("User not found")
        end
      end

      response(422, "invalid sort parameters") do
        let(:user1) { create(:user) }
        let(:user_id) { user1.id }
        let(:sort_by) { 'invalid_sort' }
        let(:sort_direction) { 'invalid_direction' }

        before do
          travel_to Time.zone.local(2024, 1, 1, 12, 0, 0)
        end

        after { travel_back }

        run_test! do |response|
          expect(response).to have_http_status(422)
          json = JSON.parse(response.body, symbolize_names: true)
          expect(json[:status]).to eq("error")
          expect(json[:data]).to be_nil
          expect(json[:message][:sort_direction]).to be_present
        end
      end
    end
  end
end
