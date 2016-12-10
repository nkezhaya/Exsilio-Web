class ApiController < ApplicationController
  acts_as_token_authentication_handler_for(User)

  def index
    render json: { status: "OK" }
  end

  protected
  def authenticate_user!
    fb_token = request.headers["X-FB-TOKEN"]

    user = if fb_token.present?
             User.from_facebook_token(fb_token)
           else
             current_user
           end

    if !user
      render json: { status: "Authentication error." }, status: :unauthorized
    else
      @current_user = user
    end
  end
end
