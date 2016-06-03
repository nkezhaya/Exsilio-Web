class Tour < ActiveRecord::Base
  include PgSearch

  belongs_to :user

  has_many :waypoints

  validates :name, presence: true

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

    options.merge! include: { waypoints: waypoints, user: user }, methods: [:polyline, :duration]

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

  def polyline
    directions["routes"][0]["overview_polyline"]["points"] rescue nil
  end

  def duration
    total_seconds = 0

    directions["routes"][0]["legs"].each do |leg|
      leg["steps"].each do |step|
        total_seconds += step["duration"]["value"]
      end
    end

    ActionController::Base.helpers.distance_of_time_in_words(total_seconds.seconds)
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
