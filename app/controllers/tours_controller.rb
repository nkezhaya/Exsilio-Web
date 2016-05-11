class ToursController < ApiController
  before_action :authenticate_user!

  def create
    tour = current_user.tours.new(tour_params)

    if tour.save
      render json: tour
    else
      render json: { errors: tour.errors.full_messages.join(". ") }
    end
  end

  private
  def tour_params
    params.require(:tour).permit(:name, :description, waypoints_attributes: [:name, :description, :position, :image])
  end
end
