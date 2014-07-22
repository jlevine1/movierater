class CreateMoviesTable < ActiveRecord::Migration
  def change
  	create_table :movies do |t|
  		t.string :title
  		t.string :rating
  		t.string :avatar
  		t.integer :user_id
  	end
  end
end
