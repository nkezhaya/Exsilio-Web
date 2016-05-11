class Waypoint < ActiveRecord::Base
  belongs_to :tour

  has_attached_file :image

  validates :name, presence: true
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
end
