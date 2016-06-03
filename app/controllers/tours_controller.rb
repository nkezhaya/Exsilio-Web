class ToursController < ApiController
  before_action :authenticate_user!

  def index
    render json: current_user.tours
  end

  def search
    tours = Tour.search(params[:query])

    render json: { total: tours.count, tours: Kaminari.paginate_array(tours).page(params[:page]).per(10) }
  end

  def show
    tour = current_user.tours.find(params[:id])

    render json: tour, full: true
  end

  def create
    tour = current_user.tours.new(tour_params)

    if tour.save
      render json: tour
    else
      render json: { errors: tour.errors.full_messages.join(". ") }
    end
  end

  def destroy
    tour = current_user.tours.find(params[:id])

    if tour.destroy
      render json: tour
    else
      render json: { errors: "Unable to delete tour." }
    end
  end

  private
  def tour_params
    params.require(:tour).permit(:name, :description, waypoints_attributes: [:name, :position, :image, :latitude, :longitude])
  end
end
