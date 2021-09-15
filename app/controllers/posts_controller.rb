require_relative '../services/post_dao'

class PostsController < ApplicationController
    before_action :authenticate_user
    before_action :check_permissions!, only: [:create, :update]

    rescue_from Exception do |e|
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
        if Current.user.nil?
            post = Post.find(params[:id], published: true)
        else
            post = Post.find(params[:id])
            if !post.user.id.eql?(Current.user.id) and !post.published
                render json: { error: 'Post not found' }, status: :not_found
                return
            end
        end

        return render json: post, status: :ok
    end

    # POST /posts/
    def create
        post = Post.create!(create_params)
        return render json: post, status: :created
    end

    # PATH /posts/{id}/ or PUT /posts/{id}/
    def update
        post = Post.where(user_id: Current.user.id).find(params[:id])
        post.update!(update_params)
        return render json: post, status: :ok
    end

    private

    def create_params
        {
            title: params.require(:title),
            content: params.require(:content),
            published: params.require(:published),
            user_id: Current.user.id
        }
    end

    def update_params
        params.permit(:title, :content, :published)
    end

    def authenticate_user
        headers = request.headers
        token_regex = /^Bearer (\w+)$/

        if headers['Authorization'].nil?
            return
        end

        if !(match = headers['Authorization'].match(token_regex))
            render json: { error: 'Token should be Bearer token' }, status: :unauthorized
            return
        end

        token = match[1]
        user = User.find_by_auth_token(token)
        if user.nil?
            render json: { error: 'Invalid token' }, status: :unauthorized
            return
        end
        Current.user = user
    end

    def check_permissions!
        if Current.user.nil?
            render json: { error: 'You should be authenticated' }, status: :unauthorized
            return
        end
    end
end