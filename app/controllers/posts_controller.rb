require 'byebug'

class PostsController < ApplicationController

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
        return render json: posts, status: :ok 
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
end