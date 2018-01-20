class PasswordsController < ApiController
  require "securerandom"
  include SendGrid

  #before_action :authenticate_user!, only: [:update]

  def create
    user = User.find_by(email: params[:email])
    password = SecureRandom.hex[0,10]
    user.password = password
    user.save!

    from = Email.new(email: "no-reply@exsilio.herokuapp.com")
    subject = "Exsilio Password Reset"
    to = Email.new(email: params[:email])
    content = Content.new(type: "text/plain", value: "New password: #{password}")
    mail = Mail.new(from, subject, to, content)

    sg = SendGrid::API.new(api_key: ENV["SENDGRID_API_KEY"])
    response = sg.client.mail._("send").post(request_body: mail.to_json)

    render json: { status: "OK" }
  end

  def update
    user = current_user
    if user.update(user_params)
      bypass_sign_in(user)
      render json: { status: "OK" }
    else
      render json: { errors: "Password was invalid or did not match confirmation." }, status: :unprocessable_entity
    end
  end

  private
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
