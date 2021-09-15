require 'rails_helper'

def auth_headers(user)
  {
    'Authorization' => "Bearer #{user.auth_token}"
  }
end

RSpec.describe 'Posts Authentications', type: :request do
  describe 'GET /posts/{id}' do
    context 'with a auth valid' do
        let!(:user) { create(:user) }
        let!(:other_user) { create(:user) }
        context 'when the user is the owner of the post' do
        end
        
        context 'when other user is the owner of the post' do
            context 'and the post is a draft' do
                let!(:post) { create(:post, user: other_user, published: false) }
                before { get "/posts/#{post.id}", headers: auth_headers(user) }
                context 'payload content error message' do
                    subject { JSON.parse(response.body) }
                    it { is_expected.to include("error") }
                end
                context 'status' do
                    subject { response }
                    it { is_expected.to have_http_status(:not_found) }
                end
            end
            context 'and the post is public' do
                let!(:post) { create(:post, user: other_user, published: true) }
                before { get "/posts/#{post.id}", headers: auth_headers(user) }
                context 'payload' do
                    subject { JSON.parse(response.body) }
                    it { is_expected.to include("id") }
                end
                context 'status' do
                    subject { response }
                    it { is_expected.to have_http_status(:ok) }
                end
            end
        end
      end
    describe 'POST /posts/' do
    end
    describe 'PATCH /posts/{id}/' do
    end
  end
end