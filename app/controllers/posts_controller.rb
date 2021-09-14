require 'byebug'

class PostsController < ApplicationController

    rescue_from Exception do |e|
        return render json: { error: e.message }, status: :internal_server_error
    end

    # GET /posts/
    def index
        posts = Post.where(:published => true)
        return render json: posts, status: :ok 
    end

    # GET /posts/{id}/
    def show
        begin
            post = Post.find(params[:id])
        rescue ActiveRecord::RecordNotFound
            return render json: { error: 'Post not found' }, status: :not_found
        end
        return render json: post, status: :ok
    end

    # POST /posts/
    def create
        begin
            post = Post.create!(create_params)
        rescue ActiveRecord::RecordInvalid, ActionController::ParameterMissing => e
            if e.message.include? 'must exist'
                return render json: { error: 'User not found' }, status: :bad_request
            end
            return render json: { error: 'Invalid Post' }, status: :bad_request
        end
        return render json: post, status: :created
    end

    # PATH /posts/{id}/
    def update
        begin
            post = Post.find(params[:id])
        rescue ActiveRecord::RecordNotFound
            return render json: { error: 'Post not found' }, status: :not_found
        end

        begin
            post.update!(update_params)
        rescue ActiveRecord::RecordInvalid
            return render json: { error: 'Invalid Post' }, status: :bad_request
        end

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