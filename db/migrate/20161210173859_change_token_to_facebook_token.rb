class ChangeTokenToFacebookToken < ActiveRecord::Migration
  def change
    rename_column :users, :token, :facebook_token
  end
end
