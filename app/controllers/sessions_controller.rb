class SessionsController < Devise::SessionsController
  def create
    user = User.find_by(email: user_params[:email])

    if user
      if user.valid_password?(user_params[:password])
        render json: { email: user.email, authentication_token: user.authentication_token }
      else
        render json: { status: "Error", error: "Invalid email/password." }
      end
    else
      render json: { status: "Error", error: "Invalid email/password." }
    end
  end

  private
  def user_params
    params.require(:user).permit(:email, :password)
  end
end
