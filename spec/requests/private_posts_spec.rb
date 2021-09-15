require 'rails_helper'

def auth_headers(user)
  {
    'Authorization' => "Bearer #{user.auth_token}"
  }
end

RSpec.describe 'Posts Authentications', type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:create_params) { {title: 'Post title', content: 'Post body', published: true,} }
  let!(:update_params) { {title: 'Post title', content: 'Post body', published: true,} }
  describe 'GET /posts/{id}' do
    context 'with a auth valid' do
      context 'when the user is the owner of the post' do
      end
      
      context 'when other user is the owner of the post' do
          context 'and the post is a draft' do
              let!(:post) { create(:post, user: other_user, published: false) }
              before { get "/posts/#{post.id}", headers: auth_headers(user) }
              context 'payload content error message' do
                  subject { payload }
                  it { is_expected.to include(:error) }
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
                  subject { payload }
                  it { is_expected.to include(:id, :title, :content, :published, :author) }
              end
              context 'status' do
                  subject { response }
                  it { is_expected.to have_http_status(:ok) }
              end
          end
      end
    end
  end

  describe 'POST /posts/' do
    context 'with auth i can create a new post' do
      before { post '/posts/', params: create_params, headers: auth_headers(user)}
      context 'Response' do
        it { expect(payload).to include("id") }
        it { expect(payload[:title]).to eq( create_params[:title]) }
        it { expect(payload[:content]).to eq( create_params[:content]) }
        it { expect(payload[:published]).to eq( create_params[:published]) }
        it { expect(payload[:author][:id]).to eq(user.id) }
      end
      context 'status' do
        subject { response }
        it { is_expected.to have_http_status(:created) }
      end
    end

    context 'without auth i cant create a new post' do
      before { post '/posts/', params: create_params }
      context 'Response' do
        subject { payload }
        it { is_expected.to include("error") }
      end
      context 'status' do
        subject { response }
        it { is_expected.to have_http_status(:unauthorized) }
      end
    end
  end

  describe 'PATCH /posts/{id}/' do
    context 'with auth' do
      context 'can update a post where im the author' do
        let(:article) { create(:post, user: user) }
        before { patch "/posts/#{article.id}/", params: update_params, headers: auth_headers(user) }
        context 'Response' do
          it { expect(payload[:title]).to eq( update_params[:title]) }
          it { expect(payload[:content]).to eq( update_params[:content]) }
          it { expect(payload[:published]).to eq( update_params[:published])}  
        end
        context 'status' do
          subject { response }
          it { is_expected.to have_http_status(:ok) }
        end
      end
      context 'cant update a post where im not the author' do
        let(:article) { create(:post, user: other_user) }
        before { patch "/posts/#{article.id}/", params: update_params, headers: auth_headers(user)}
        context 'Response' do
          it { expect(payload).to include("error") }
        end
        context 'status' do
          subject { response }
          it { is_expected.to have_http_status(:not_found) }
        end
      end
    end
    context 'without auth i cant update any post' do
      let(:article) { create(:post) }
      before { patch "/posts/#{article.id}/", params: update_params }
      context 'Response' do
        subject { payload }
        it { is_expected.to include("error") }
      end
      context 'status' do
        subject { response }
        it { is_expected.to have_http_status(:unauthorized) }
      end  
    end
  end

  private
  def payload
    JSON.parse(response.body).with_indifferent_access
  end
end
