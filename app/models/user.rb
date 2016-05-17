class User < ActiveRecord::Base
  attr_reader :picture_remote_url
  has_attached_file :picture

  has_many :tours

  def self.from_token(token)
    graph = Koala::Facebook::API.new(token)
    me = graph.api("/me?fields=id,first_name,last_name,email,gender,picture")

    where(facebook_uid: me["id"]).first_or_create do |user|
      user.email = me["email"]
      user.first_name = me["first_name"]
      user.last_name = me["last_name"]
      user.picture_remote_url = me["picture"]["data"]["url"] rescue nil
      user.token = token
    end
  end

  def picture_remote_url=(url)
    self.picture = URI.parse(url) if url.present?
    @picture_remote_url = url
  end
end
