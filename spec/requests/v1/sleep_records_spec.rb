require "swagger_helper"

RSpec.describe "V1::SleepRecords", type: :request do
  include_context "container setup"

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
end
