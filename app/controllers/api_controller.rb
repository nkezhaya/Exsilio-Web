class ApiController < ApplicationController
  def index
    render json: { status: "OK" }
  end

  protected
  def authenticate_user!
    token = request.headers["HTTP_X_TOKEN"]
    user = User.from_token(token) if token.present?

    if !user
      render json: { status: "Authentication error." }, status: :unauthorized
    else
      @current_user = user
    end
  end

  def current_user
    @current_user
  end
end
