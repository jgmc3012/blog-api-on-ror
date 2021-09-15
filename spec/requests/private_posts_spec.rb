require 'rails_helper'

def auth_headers(user)
  {
    'Authorization' => "Bearer #{user.auth_token}"
  }
end

RSpec.describe 'Posts Authentications', type: :request do
  describe 'GET /posts/{id}' do
    let!(:user) { create(:user) }
    let!(:other_user) { create(:user) }
    context 'with a auth valid' do
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
      it 'with auth i can create a new post' do
        post_params = {
          title: 'Post title',
          content: 'Post body',
          published: true,
        }
        post '/posts/', params: post_params, headers: auth_headers(user)
  
        expect(response).to have_http_status(:created)
      end

      it 'without auth i cant create a new post' do
        post_params = {
          title: 'Post title',
          content: 'Post body',
          published: true,
        }
        post '/posts/', params: post_params
  
        expect(response).to have_http_status(:unauthorized)
      end

    end

    describe 'PATCH /posts/{id}/' do
      context 'with auth' do
        it 'can update a post where im the author' do
          article = create(:post, user: user)
          article_params = {
            title: 'Post title',
          } 
          patch "/posts/#{article.id}/", params: article_params, headers: auth_headers(user)
    
          payload = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(payload['title']).to eq(article_params[:title])

        end
        it 'cant update a post where im not the author' do
          article = create(:post, user: other_user)
          article_params = {
            title: 'Post title',
          } 
          patch "/posts/#{article.id}/", params: article_params, headers: auth_headers(user)
    
          expect(response).to have_http_status(:unauthorized)
        end
      end
      it 'without auth i cant update any post' do
        article =  create(:post)
        article_params = {
          title: 'Post title',
        } 
        patch "/posts/#{article.id}/", params: article_params
  
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end