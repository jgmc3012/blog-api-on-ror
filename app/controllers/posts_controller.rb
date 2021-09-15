require_relative '../services/post_dao'

class PostsController < ApplicationController
    before_action :authenticate_user!, only: [:create, :update]

    rescue_from Exception do |e|
        byebug
        render json: { error: e.message }, status: :internal_server_error
    end

    rescue_from ActiveRecord::RecordInvalid, ActionController::ParameterMissing do |e|
        if e.message.include? 'must exist'
            render json: { error: 'User not found' }, status: :bad_request
        else
            render json: { error: 'Invalid Post' }, status: :bad_request
        end
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
        render json: { error: 'Post not found' }, status: :not_found
    end

    # GET /posts/
    def index
        posts = Post.where(:published => true)
        if !params[:title].nil?
            posts = PostDao.search_by_title(posts, params[:title])
        end
        return render json: posts.includes(:user), status: :ok 
    end

    # GET /posts/{id}/
    def show
        post = Post.find(params[:id])
        return render json: post, status: :ok
    end

    # POST /posts/
    def create
        post = Post.create!(create_params)
        return render json: post, status: :created
    end

    # PATH /posts/{id}/ or PUT /posts/{id}/
    def update
        post = Post.find(params[:id])
        post.update!(update_params)
        return render json: post, status: :ok
    end

    private

    def create_params
        {
            title: params.require(:title),
            content: params.require(:content),
            published: params.require(:published),
            user_id: params.require(:user_id)
        }
    end

    def update_params
        params.permit(:title, :content, :published)
    end

    def authenticate_user!
        headers = request.headers
        token_regex = /^Bearer (\w+)$/
        if headers['Authorization'].nil?
            render json: { error: 'Should provide a token' }, status: :unauthorized
            return
        end

        if !(match = headers['Authorization'].match(token_regex))
            render json: { error: 'Token should be Bearer token' }, status: :unauthorized
            return
        end
        token = match[1]
        user = User.find_by_token(token)
        if user.nil?
            render json: { error: 'Invalid token' }, status: :unauthorized
            return
        end
        Current.user = user
    end
end