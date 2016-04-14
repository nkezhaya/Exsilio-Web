class User < ActiveRecord::Base
  def self.from_token(token)
    graph = Koala::Facebook::API.new(token)
    me = graph.api("/me?fields=id,first_name,last_name,email,gender,picture")

    where(facebook_uid: me["id"]).first_or_create do |user|
      user.email = me["email"]
      user.first_name = me["first_name"]
      user.last_name = me["last_name"]
      user.token = token
    end
  end
end
