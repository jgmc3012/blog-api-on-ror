require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  describe 'GET /posts/' do
    describe "without data in the DB" do
      it 'should be return body empty' do
        get '/posts/'
        expect(JSON.parse(response.body)).to be_empty
        expect(response).to have_http_status(200)
      end
    end

    describe "with data in the DB" do
      let!(:posts) { create_list(:post, 10, published: true) } # create_list is a helper method from FactoryBot
      it 'should return all the published posts' do
        get '/posts/'
        payload = JSON.parse(response.body)
        expect(payload.size).to eq(posts.size)
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /posts/{id}/' do
    describe "without data in the DB" do
      it 'should return status not found' do
        get '/posts/1/'
        payload = JSON.parse(response.body)
        expect(payload['error']).to eq('Post not found') 
        expect(response).to have_http_status(404)
      end
    end

    describe "with data in the DB" do
      let(:post) { create(:post) } # create is a helper method from FactoryBot
      before { get "/posts/#{post.id}" }

      it 'should return the post' do
        payload = JSON.parse(response.body)
        expect(payload['id']).to eq(post.id)
        expect(response).to have_http_status(200)
      end
    end
  end
end