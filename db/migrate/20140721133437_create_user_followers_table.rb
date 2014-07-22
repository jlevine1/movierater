class CreateUserFollowersTable < ActiveRecord::Migration
  def change
  	create_table :user_followers do |t|
  		t.integer :user_id
  		t.integer :other_user_id
  	end
  end
end
