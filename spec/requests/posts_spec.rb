require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  describe 'GET /posts/' do
    describe "without data in the DB" do
      it 'should be return body empty' do
        get '/posts/'
        expect(JSON.parse(response.body)).to be_empty
        expect(response).to have_http_status(:ok)
      end
    end

    describe "with data in the DB" do
      it 'should return all the published posts' do
        posts = create_list(:post, 10, published: true) # create_list is a helper method from FactoryBot
        get '/posts/'
        expect(response).to have_http_status(:ok)
        payload = JSON.parse(response.body)
        expect(payload.size).to eq(posts.size)
      end
      
      it 'search by title' do
        python = create(:post, title: 'Course of Python', published: true)
        async = create(:post, title: 'Async and IO', published: true)
        golang = create(:post, title: 'Course of golang', published: true)
        get '/posts/?title=Course'
        expect(response).to have_http_status(:ok)
        payload = JSON.parse(response.body)
        expect(payload.size).to eq(2)
        expect(payload.map { |p| p['id'] }.sort).to eq([golang.id, python.id].sort)
      end
    end
  end

  describe 'GET /posts/{id}/' do
    describe "without data in the DB" do
      it 'should return status not found' do
        get '/posts/1/'
        payload = JSON.parse(response.body)
        expect(payload['error']).to eq('Post not found') 
        expect(response).to have_http_status(:not_found)
      end
    end

    describe "with data in the DB" do
      let(:post) { create(:post) } # create is a helper method from FactoryBot
      before { get "/posts/#{post.id}" }

      it 'should return the post' do
        payload = JSON.parse(response.body)
        expect(payload['id']).to eq(post.id)
        expect(payload['title']).to eq(post.title)
        expect(payload['content']).to eq(post.content)
        expect(payload['published']).to eq(post.published)
        expect(payload['author']['id']).to eq(post.user.id)
        expect(payload['author']['name']).to eq(post.user.name)
        expect(payload['author']['email']).to eq(post.user.email)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST /posts/' do
    let(:user) { create(:user) }
    it 'should create a new post' do
      post_params = {
        title: 'Post title',
        content: 'Post body',
        published: true,
        user_id: user.id
      }
      post '/posts/', params: post_params

      payload = JSON.parse(response.body)
      expect(response).to have_http_status(:created)
      expect(payload['title']).to eq(post_params[:title])
    end

    it 'should return an error if the params have empty values' do
      post_params = {
        title: '',
        content: '',
        published: true,
        user_id: user.id
      }
      post '/posts/', params: post_params

      payload = JSON.parse(response.body)
      expect(response).to have_http_status(:bad_request)
      expect(payload['error']).to eq('Invalid Post')
    end

    it 'should return an error if user not found' do
      post_params = {
        title: 'Post title',
        content: 'Post body',
        published: true,
        user_id: 'hello'
      }
      post '/posts/', params: post_params

      payload = JSON.parse(response.body)
      expect(response).to have_http_status(:bad_request)
      expect(payload['error']).to eq('User not found')
    end

  end

  describe 'PATCH /posts/{id}/' do
    let(:article) { create(:post) }
    it 'should partial update a post' do
      article_params = {
        title: 'Post title',
        content: 'Post body',
        published: !article.published
      } 
      patch "/posts/#{article.id}/", params: article_params

      payload = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(payload['title']).to eq(article_params[:title])
      expect(payload['content']).to eq(article_params[:content])
      expect(payload['published']).to eq(article_params[:published])

    end

    it 'should return an error if the post is not valid' do
      article_params = {
        title: nil,
        content: nil
      } 
      patch "/posts/#{article.id}/", params: article_params

      payload = JSON.parse(response.body)
      expect(response).to have_http_status(:bad_request)
      expect(payload['error']).to eq('Invalid Post')
    end

    it 'should return an error if the post is not found' do
      article_params = {
        title: 'Post title',
        content: 'Post body',
        published: true
      } 
      patch "/posts/1/", params: article_params

      payload = JSON.parse(response.body)
      expect(response).to have_http_status(:not_found)
      expect(payload['error']).to eq('Post not found')
    end
  end

end