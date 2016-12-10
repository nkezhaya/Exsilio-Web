class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable

  acts_as_token_authenticatable

  attr_reader :picture_remote_url
  has_attached_file :picture
  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\Z/

  has_many :tours

  def self.from_facebook_token(token)
    return false if token.blank?

    graph = Koala::Facebook::API.new(token)
    me = Rails.cache.fetch("#{Digest::SHA1.hexdigest(token)}/me", expires_in: 24.hours) do
      graph.api("/me?fields=id,first_name,last_name,email,gender")
    end

    where(facebook_uid: me["id"]).first_or_create do |user|
      user.email = me["email"]
      user.first_name = me["first_name"]
      user.last_name = me["last_name"]
      user.picture_remote_url = graph.get_picture("me", type: "large") rescue nil
      user.facebook_token = token
    end
  end

  def picture_remote_url=(url)
    self.picture = URI.parse(url) if url.present?
    @picture_remote_url = url
  end

  def picture_url
    picture.url(:original)
  end

  def as_json(options = {})
    super(options.merge(methods: :user_picture_url, except: [:authentication_token, :facebook_token]))
  end
end
