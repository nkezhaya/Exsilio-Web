class Tour < ActiveRecord::Base
  include PgSearch

  belongs_to :user

  has_many :waypoints, dependent: :destroy

  validates :name, presence: true
  validate do |tour|
    if tour.waypoints.length < 2
      tour.errors.add(:base, "Need at least two waypoints.")
    end
  end

  accepts_nested_attributes_for :waypoints

  before_save :set_directions

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
      methods: [:polyline, :duration, :duration_short, :distance, :display_image_url]

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

  def display_image_url
    self.waypoints.find { |waypoint|
      waypoint.image.present?
    }.try(:image).try(:url, :original)
  end

  def polyline
    directions["routes"][0]["overview_polyline"]["points"] rescue nil
  end

  def duration
    total_seconds = 0

    return "0 seconds" if directions.blank? || directions["routes"].blank?

    directions["routes"][0]["legs"].each do |leg|
      leg["steps"].each do |step|
        total_seconds += step["duration"]["value"]
      end
    end

    ActionController::Base.helpers.distance_of_time_in_words(total_seconds.seconds)
  end

  def duration_short
    long_duration = self.duration

    return "" if long_duration.blank?

    long_duration.gsub(" hours", "h").gsub(" minutes", "m").gsub(" seconds", "s")
  end

  def distance
    total_meters = 0.0

    return "0 mi" if directions.blank? || directions["routes"].blank?

    directions["routes"][0]["legs"].each do |leg|
      leg["steps"].each do |step|
        total_meters += step["distance"]["value"]
      end
    end

    "#{((total_meters / 1000.0) * 0.621371).round(1)} mi"
  end

  def set_directions
    url = "https://maps.googleapis.com/maps/api/directions/json?key=#{Figaro.env.google_maps_key}"
    waypoint_coordinates = waypoints.map { |waypoint| waypoint.coordinates_string }

    url << "&origin=#{waypoint_coordinates.shift}"
    url << "&destination=#{waypoint_coordinates.pop}"

    if waypoint_coordinates.count > 0
      url << "&waypoints=#{waypoint_coordinates.join("|")}"
    end

    begin
      self.directions = RestClient.get(url)
    rescue
      puts "Exception: #{url}"
    end
  end
end
