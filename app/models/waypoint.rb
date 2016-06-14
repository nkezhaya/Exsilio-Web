class Waypoint < ActiveRecord::Base
  belongs_to :tour, counter_cache: true

  default_scope -> { order("position ASC") }

  has_attached_file :image

  reverse_geocoded_by :latitude, :longitude do |obj, results|
    if geo = results.first
      obj.address = geo.address
      obj.city = geo.city
      obj.state = geo.state
    end
  end

  after_validation :reverse_geocode

  validates :name, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  def coordinates_string
    "#{latitude},#{longitude}"
  end

  def latitude
    read_attribute(:latitude).to_f
  end

  def longitude
    read_attribute(:longitude).to_f
  end

  def image_url
    image.url(:original)
  end
end
