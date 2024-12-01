require "swagger_helper"

RSpec.describe "V1::SleepRecords", type: :request do
  include_context "container setup"

  path "/v1/sleep_records" do
    get("List user's sleep records") do
      tags "Sleep Records"
      consumes "application/json"
      produces "application/json"
      parameter name: :user_id, in: :query, type: :integer, required: true
      parameter name: :sort_by, in: :query, type: :string, required: true
      parameter name: :sort_direction, in: :query, type: :string, required: true

      response(200, "successful") do
        let(:user) { create(:user) }
        let!(:older_record) { create(:sleep_record, user: user, clock_in: 2.days.ago, clock_out: 1.day.ago) }
        let!(:newer_record) { create(:sleep_record, user: user, clock_in: 1.day.ago, clock_out: Time.current) }
        let(:user_id) { user.id }
        let(:sort_by) { "created_at" }
        let(:sort_direction) { "desc" }

        run_test! do |response|
          expect(response).to have_http_status(200)

          json = JSON.parse(response.body, symbolize_names: true)
          expect(json[:data]).to be_an(Array)
          expect(json[:data].length).to eq(2)

          records = json[:data].sort_by { |r| r[:id] }
          expect(records.map { |r| r[:id] }).to match_array([ older_record.id, newer_record.id ])
          expect(records.map { |r| r[:user_id] }).to all(eq(user.id))
          expect(records.map { |r| r[:clock_in] }).to all(be_present)
          expect(records.map { |r| r[:clock_out] }).to all(be_present)

          expect(json[:message]).to eq("Successfully fetched sleep records")
          expect(json[:status]).to eq("success")
        end
      end

      response(422, "invalid parameters") do
        let(:user_id) { 1 }
        let(:sort_by) { "invalid" }
        let(:sort_direction) { "invalid" }

        run_test! do |response|
          expect(response).to have_http_status(422)

          json = JSON.parse(response.body, symbolize_names: true)
          expect(json[:message]).to eq({ sort_direction: [ "must be one of: asc, desc" ] })
        end
      end
    end
  end

  path "/v1/sleep_records/clock_in" do
    post("Clock in a user's sleep time") do
      tags "Sleep Records"
      consumes "application/json"
      produces "application/json"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          user_id: { type: :integer, description: "ID of the user" }
        },
        required: [ "user_id" ]
      }

      response(201, "successful") do
        let(:user) { create(:user) }
        let(:params) { { user_id: user.id } }

        run_test! do |response|
          expect(response).to have_http_status(201)

          json = JSON.parse(response.body, symbolize_names: true)
          expect(json[:data]).to include(
            id: be_present,
            user_id: user.id,
            clock_in: be_present,
            clock_out: nil
          )
          expect(json[:message]).to eq("Successfully clocked in")
          expect(json[:status]).to eq("success")
        end
      end

      response(404, "user not found") do
        let(:params) { { user_id: -1 } }

        run_test! do |response|
          expect(response).to have_http_status(404)

          json = JSON.parse(response.body, symbolize_names: true)
          expect(json[:message]).to eq("User not found")
        end
      end

      response(422, "user already clocked in") do
        let(:user) { create(:user) }
        let(:params) { { user_id: user.id } }

        before do
          create(:sleep_record, user: user, clock_in: Time.current, clock_out: nil)
        end

        run_test! do |response|
          expect(response).to have_http_status(422)

          json = JSON.parse(response.body, symbolize_names: true)
          expect(json[:message]).to eq("User already has an active sleep record")
        end
      end
    end
  end

  path "/v1/sleep_records/clock_out" do
    post("Clock out a user's sleep time") do
      tags "Sleep Records"
      consumes "application/json"
      produces "application/json"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          user_id: { type: :integer, description: "ID of the user" }
        },
        required: [ "user_id" ]
      }

      response(201, "successful") do
        let(:user) { create(:user) }
        let!(:sleep_record) { create(:sleep_record, user: user, clock_out: nil) }
        let(:params) { { user_id: user.id } }

        run_test! do |response|
          expect(response).to have_http_status(201)

          json = JSON.parse(response.body, symbolize_names: true)
          expect(json[:data]).to include(
            id: sleep_record.id,
            user_id: user.id,
            clock_in: be_present,
            clock_out: be_present
          )
          expect(json[:message]).to eq("Successfully clocked out")
          expect(json[:status]).to eq("success")
        end
      end

      response(404, "sleep record not found") do
        let(:params) { { user_id: -1 } }

        run_test! do |response|
          expect(response).to have_http_status(404)

          json = JSON.parse(response.body, symbolize_names: true)
          expect(json[:message]).to eq("SleepRecord not found")
        end
      end

      response(404, "no active sleep record") do
        let(:user) { create(:user) }
        let(:params) { { user_id: user.id } }

        run_test! do |response|
          expect(response).to have_http_status(404)

          json = JSON.parse(response.body, symbolize_names: true)
          expect(json[:message]).to eq("SleepRecord not found")
        end
      end

      response(404, "already clocked out") do
        let(:user) { create(:user) }
        let!(:sleep_record) { create(:sleep_record, user: user, clock_out: Time.current) }
        let(:params) { { user_id: user.id } }

        run_test! do |response|
          expect(response).to have_http_status(404)

          json = JSON.parse(response.body, symbolize_names: true)
          expect(json[:message]).to eq("SleepRecord not found")
        end
      end
    end
  end
end
