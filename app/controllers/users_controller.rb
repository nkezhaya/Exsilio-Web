class UsersController < ApplicationController
  def create
    user = User.from_token(user_param[:token])

    if user.save
      render json: { status: "Success" }
    else
      render json: { status: "Error" }
    end
  end

  private
  def user_param
    params.require(:user).permit(:token)
  end
end
