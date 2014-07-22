class AvatarUploader < CarrierWave::Uploader::Base
	storage :file
	def store_dir
    	'my/upload/directory'
  	end
  
  	def extension_white_list
  		%w(jpg jpeg gif png)
  	end
end

class User <ActiveRecord::Base
	has_one :profile
	has_many :posts
	has_many :user_followers
	has_many :users, through: :user_followers
	has_many :post_likes
	has_many :posts, through: :post_likes
	has_many :movies
end

class Profile<ActiveRecord::Base
	belongs_to :user
end

class Post<ActiveRecord::Base
	belongs_to :user
	has_many :post_likes
	has_many :users, through: :post_likes
	belongs_to :movies
end

class UserFollower<ActiveRecord::Base
	belongs_to :user
end

class PostLikes<ActiveRecord::Base
	belongs_to :user
	belongs_to :post
end

class Movie<ActiveRecord::Base
	has_many :posts
	has_one :user
	mount_uploader :avatar, AvatarUploader
end

