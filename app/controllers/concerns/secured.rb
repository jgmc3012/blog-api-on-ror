module Secured
    private
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