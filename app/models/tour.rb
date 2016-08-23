class Tour < ActiveRecord::Base
  include PgSearch

  belongs_to :user

  has_many :waypoints, dependent: :destroy

  validates :name, presence: true
  validate do |tour|
    if tour.published?
      if tour.waypoints.length < 2
        tour.errors.add(:base, "Need at least two waypoints.")
      end
    end
  end

  accepts_nested_attributes_for :waypoints

  before_save :set_latitude_and_longitude

  geocoded_by nil

  scope :published, -> { where(published: true) }
  scope :filters, ->(params) {
    query = where(nil)

    if min_waypoints = params.delete(:min_waypoints)
      query = query.where("waypoints_count >= ?", min_waypoints)
    end

    if max_waypoints = params.delete(:max_waypoints)
      query = query.where("waypoints_count <= ?", max_waypoints)
    end

    if min_seconds = params.delete(:min_seconds_required)
      query = query.where("total_time_in_seconds >= ?", min_seconds)
    end

    if max_seconds = params.delete(:max_seconds_required)
      query = query.where("total_time_in_seconds <= ?", max_seconds)
    end

    current_location = params.delete(:current_location)

    if current_location.present?
      current_location = [current_location[:latitude], current_location[:longitude]].map(&:to_f)
      sort_by_distance = params.delete(:sort_by) == "Distance From Current Location"
      max_distance = (params.delete(:max_distance_from_current_location) || 999999).to_i

      args = [current_location, max_distance, units: :mi]
      args.last[:order] = "distance" if sort_by_distance

      query = query.near(*args)
    end

    return query
  }

  pg_search_scope :search,
    against: [:name, :description],
    associated_against: {
      waypoints: [:name],
      user: [:first_name, :last_name]
    }

  def as_json(options = {})
    full = options.delete(:full) == true
    user = {
      except: :token,
      methods: :picture_url
    }

    waypoints = {
      methods: :image_url
    }

    options.merge! include: { waypoints: waypoints, user: user },
      methods: [:duration, :duration_short, :distance, :display_image_url, :city_state]

    if !full
      options.merge! except: :directions
    end

    super(options)
  end

  def reposition_waypoints!(ids)
    position = 0

    ids.each do |id|
      self.waypoints.find(id).update_column(:position, position)

      position += 1
    end

    return true
  end

  def city_state
    if waypoint = waypoints.first
      "#{waypoint.city}, #{waypoint.state}"
    else
      "--"
    end
  end

  def display_image_url
    self.waypoints.find { |waypoint|
      waypoint.image.present?
    }.try(:image).try(:url, :original)
  end

  def duration
    return "0 seconds" if route.blank?

    ActionController::Base.helpers.distance_of_time_in_words(total_time_in_seconds.seconds)
  end

  def duration_short
    long_duration = self.duration

    return "" if long_duration.blank?

    long_duration.gsub(" hours", "h").gsub(" minutes", "m").gsub(" seconds", "s")
  end

  def distance
    total_meters = 0.0

    return "0 mi" if directions.blank? || directions["routes"].blank?

    legs.each do |leg|
      leg["steps"].each do |step|
        total_meters += step["distance"]["value"]
      end
    end

    "#{((total_meters / 1000.0) * 0.621371).round(1)} mi"
  end

  def set_latitude_and_longitude
    self.latitude = self.waypoints.first.try(:latitude)
    self.longitude = self.waypoints.first.try(:longitude)
  end

  def set_directions
    self.directions = get_directions()

    return true if self.directions.blank?

    total_seconds = 0

    legs.each do |leg|
      leg["steps"].each do |step|
        total_seconds += step["duration"]["value"]
      end
    end

    self.total_time_in_seconds = total_seconds
  end

  def get_directions(starting_coordinates_string = nil)
    return nil if waypoints.length < 2

    url = "https://maps.googleapis.com/maps/api/directions/json?key=#{Figaro.env.google_maps_key}"

    if starting_coordinates_string.present?
      url << "&origin=#{starting_coordinates_string}"
      url << "&destination=#{waypoints.first.coordinates_string}"
      url << "&mode=driving"
    else
      waypoint_coordinates = waypoints.map { |waypoint| waypoint.coordinates_string }

      url << "&origin=#{waypoint_coordinates.shift}"
      url << "&destination=#{waypoint_coordinates.pop}"
      url << "&mode=walking"

      if waypoint_coordinates.count > 0
        url << "&waypoints=#{waypoint_coordinates.join("|")}"
      end
    end

    begin
      return RestClient.get(url)
    rescue
      puts "Exception: #{url}"
      return nil
    end
  end

  def legs
    route["legs"] || []
  rescue
    []
  end

  def route
    self.directions["routes"][0] || {}
  rescue
    {}
  end
end
