class UsersController < ApiController
  before_action :authenticate_user!

  def me
    render json: { user: current_user }
  end
end
