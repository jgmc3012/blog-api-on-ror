class PostsController < ApplicationController

    # GET /posts/
    def index
        posts = Post.where(:published => true)
        render json: posts, status: :ok 
    end

    # GET /posts/{id}/
    def show
        begin
            post = Post.find(params[:id])
        rescue ActiveRecord::RecordNotFound
            render json: { error: 'Post not found' }, status: :not_found
        else
            render json: post, status: :ok
        end
    end

    # POST /posts/
    def create
        begin
            post = Post.create(create_params)
        rescue ActiveRecord::RecordInvalid
            render json: post.errors, status: :bad_request
        rescue ActionController::ParameterMissing
            render json: { error: 'Missing parameters or the value is empty' }, status: :bad_request
        else
            render json: post, status: :created
        end
    end

    def create_params
        {
            title: params.require(:title),
            content: params.require(:content),
            published: params.require(:published),
            user_id: params.require(:user_id)
        }
    end
end