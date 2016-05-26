class User < ActiveRecord::Base
  attr_reader :picture_remote_url
  has_attached_file :picture
  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\Z/

  has_many :tours

  def self.from_token(token)
    return false if token.blank?

    graph = Koala::Facebook::API.new(token)
    me = graph.api("/me?fields=id,first_name,last_name,email,gender")

    where(facebook_uid: me["id"]).first_or_create do |user|
      user.email = me["email"]
      user.first_name = me["first_name"]
      user.last_name = me["last_name"]
      user.picture_remote_url = graph.get_picture("me", type: "large") rescue nil
      user.token = token
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
    super(options.merge(methods: :user_picture_url, except: :token))
  end
end
