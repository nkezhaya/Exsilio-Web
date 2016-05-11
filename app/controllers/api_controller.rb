class ApiController < ApplicationController
  def index
    render json: { status: "OK" }
  end

  protected
  def authenticate_user!
    token = request.headers["HTTP_X_TOKEN"]

    if !User.exists?(token: token) && !User.from_token(token)
      render json: { status: "Authentication error." }, status: :unauthorized
    end
  end
end
