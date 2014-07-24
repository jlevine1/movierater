class CreateProfilePostsTable < ActiveRecord::Migration
  def change
  	create_table :profile_posts do |t|
  		t.string :data
  		t.string :author
  		t.datetime :created_at
  		t.integer :user_id
  		t.integer :profile_id
  	end
  end
end