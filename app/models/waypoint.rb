class Waypoint < ActiveRecord::Base
  belongs_to :tour

  default_scope -> { order("position ASC") }

  has_attached_file :image

  reverse_geocoded_by :latitude, :longitude
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
