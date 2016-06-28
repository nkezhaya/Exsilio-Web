class ToursController < ApiController
  before_action :authenticate_user!

  def index
    render json: current_user.tours.order("published ASC, created_at DESC")
  end

  def search
    tours = Tour.published.filters(params).search(params[:query])

    render json: { total: tours.count(:all), tours: Kaminari.paginate_array(tours).page(params[:page]).per(10) }
  end

  def show
    tour = current_user.tours.find(params[:id])

    render json: tour, full: true
  end

  def start
    tour = current_user.tours.find(params[:id])

    render json: tour.get_directions("#{params[:latitude].to_f},#{params[:longitude].to_f}")
  end

  def create
    tour = current_user.tours.new(tour_params)

    if tour.save
      render json: tour
    else
      render json: { errors: tour.errors.full_messages.join(". ") }
    end
  end

  def update
    tour = current_user.tours.find(params[:id])

    if tour.update_attributes(tour_params)
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
    params.require(:tour).permit(:name, :description, :published, waypoints_attributes: [:name, :position, :image, :latitude, :longitude])
  end
end
