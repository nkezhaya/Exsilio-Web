class ForgotPasswordController < ApplicationController
  require "securerandom"
  include SendGrid

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
end
