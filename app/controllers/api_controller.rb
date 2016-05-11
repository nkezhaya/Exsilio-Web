class ApiController < ApplicationController
  def index
    render json: { status: "OK" }
  end

  protected
  def authenticate_user!
    token = request.headers["HTTP_X_TOKEN"]
    user = User.find_by(token: token) || User.from_token(token)

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
