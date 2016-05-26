class WaypointsController < ApiController
  before_action :authenticate_user!
  before_action :set_tour

  def update
    waypoint = @tour.waypoints.find(params[:id])

    if waypoint.update_attributes(waypoint_params)
      render json: waypoint
    else
      render json: { errors: waypoint.errors.full_messages.join(". ") }
    end
  end

  def destroy
    waypoint = @tour.waypoints.find(params[:id])

    if waypoint.destroy
      render json: waypoint
    else
      render json: { errors: "Unable to delete waypoint." }
    end
  end

  private
  def set_tour
    @tour = current_user.tours.find(params[:tour_id])
  end

  def waypoint_params
    params.require(:waypoint).permit(:name, :position, :image, :latitude, :longitude)
  end
end
