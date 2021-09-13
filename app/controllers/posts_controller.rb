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
end