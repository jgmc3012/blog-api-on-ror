require 'rails_helper'

RSpec.describe 'Health endpoint', type: :request do
  describe 'GET /health' do
    before { get '/health/' }

    it 'returns a status Not content' do
      expect(response.body).to be_empty
    end

    it 'dont have content body' do
      expect(response).to have_http_status(204)
    end

  end
end