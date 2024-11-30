require 'swagger_helper'

RSpec.describe 'Health Check API', type: :request do
  path '/ping' do
    get 'Health check endpoint' do
      tags 'Health Check'
      produces 'text/plain'

      response '200', 'server is alive' do
        run_test! do |response|
          expect(response.body).to eq('pong')
        end
      end
    end
  end
end
