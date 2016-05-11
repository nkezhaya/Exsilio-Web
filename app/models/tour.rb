class Tour < ActiveRecord::Base
  belongs_to :user

  has_many :waypoints

  validates :name, presence: true
  
  accepts_nested_attributes_for :waypoints
end
