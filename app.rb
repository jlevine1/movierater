require 'sinatra'
require 'sinatra/activerecord'
require 'carrierwave'
require 'carrierwave/orm/activerecord'

configure(:development) {set :database, "sqlite3:example3.sqlite3"}

require './models'
require 'bundler/setup'
require 'rack-flash'

set :sessions, true
use Rack::Flash, :sweep=>true

def current_user
	if session[:user_id]
		if @current_user=User.find(session[:user_id]).blank? then redirect '/sign-in' else @current_user=User.find(session[:user_id]) end
	else
		redirect '/sign-in'
	end
end

get '/' do
	redirect '/sign-in'
end

get '/sign-in' do
	erb :sign_in
end

get '/sign-in2' do
	erb :sign_in2
end

post '/sign-in-process' do
	@user=User.find_by_username params[:username]
	if @user && @user.password==params[:password]
		flash[:message]="Success"
		session[:user_id]=@user.id
		redirect '/movies'
	else
		flash[:message]="Failed"
		redirect '/sign-in'
	end
end

post '/sign-in-process2' do
	@user=User.find_by_username params[:username]
	if @user && @user.password==params[:password]
		flash[:message]="Success"
		session[:user_id]=@user.id
		redirect '/delete-account'
	else
		flash[:message]="Failed"
		redirect '/sign-in2'
	end
end

get '/sign-up' do
	erb :sign_up
end

post '/sign-up-process' do
	if User.find_by_username(params[:username])
		flash[:message]="This username is already taken!"
		redirect '/sign-up'
	else
		User.create()
		Profile.create()
		@profile = Profile.last
		@user = User.last
		@profile.fav_movie = params[:fav_movie]
		@profile.email = params[:email]
		@user.username = params[:username]
		@user.password = params[:password]
		@profile.user_id = @user.id
		@user.save
		@profile.save
		redirect '/sign-in'
	end
end

get '/edit-profile' do
	@movie=Movie.all()
	@mlikes=MovieLikes.where(user_id:session[:user_id])
	if (@mlikes == nil)
		@mlikes = []
	end
	@plikes=PostLikes.where(user_id:session[:user_id])
	if (@plikes == nil)
		@plikes = []
	end
	@current_user=User.find(session[:user_id])
	@profile=User.find(@current_user.id).profile
	erb :edit_profile
end

post '/edit-profile-process' do
	current_user
	puts @current_user.id
	@profile=User.find(@current_user.id).profile
	@profile.fav_movie=params[:fav_movie]
	@profile.email=params[:email]
	@current_user.password=params[:password]
	@current_user.save
	@profile.save
	redirect "/user/#{@current_user.id}"
end

get '/add-movie' do
	if (@mlikes == nil)
		@mlikes = []
	end

	if (@plikes == nil)
		@plikes = []
	end

	@movie=Movie.all()
	@mlikes=MovieLikes.where(user_id:session[:user_id])
	@plikes=PostLikes.where(user_id:session[:user_id])
	@current_user=User.find(session[:user_id])
	@profile=User.find(@current_user.id).profile
	erb :add_movie
end

post '/add-movie-process' do
	current_user
	Movie.create()
	@movie = Movie.last
	@movie.title=params[:movie_title]
	@movie.avatar=params[:movie_pic]
	@movie.rating=params[:stars]
	@movie.review=params[:review]
	@movie.user_id= @current_user.id
	@movie.save
	redirect '/movies'
end

get '/delete-account' do
	User.destroy(session[:user_id])
	Profile.destroy(session[:user_id])
	
	a = PostLikes.where(user_id:session[:user_id]);
	a.each do |n|
	PostLikes.destroy(n.id)
	end
	
	a = MovieLikes.where(user_id:session[:user_id]);
	a.each do |n|
	MovieLikes.destroy(n.id)
	end
	
	a = Post.where(user_id:session[:user_id]);
	a.each do |n|
	Post.destroy(n.id)
	end
	
	a=ProfilePosts.where(user_id:session[:user_id]);
	a.each do |n|
	ProfilePosts.destroy(n.id)
	end
	
	a=Movie.where(user_id:session[:user_id]);
	a.each do |n|
	Movie.destroy(n.id)
	end

	session.clear
	redirect '/sign-in'
end

get '/delete-post/:id' do
	Post.destroy(params[:id])

	a = PostLikes.where(post_id: params[:id])
	a.each do |n|
	PostLikes.destroy(n.id)
	end

	redirect "/movie/#{session[:cur_movie]}"
end

get '/delete-review/:id' do
	Movie.destroy(params[:id])

	a = MovieLikes.where(movie_id: params[:id])
	a.each do |n|
	MovieLikes.destroy(n.id)
	end

	a=Post.where(movie_id: params[:id])
	a.each do |n|
		b=PostLikes.where(post_id: n.id)
		b.each do|n|
			PostLikes.destroy(n.id)
		end
		Post.destroy(n.id)
	end
	redirect '/movies'
end

get '/user/:id' do
	@current_user=User.find(session[:user_id])
	@profile=User.find(session[:user_id]).profile
	@user=User.find(params[:id]);
	@current_profile=Profile.find_by_user_id(params[:id])
	@recent_post=Post.where(user_id:params[:id])
	@recent_review=Movie.where(user_id:params[:id])
	@mlikes=MovieLikes.where(user_id:session[:user_id])
	@plikes=PostLikes.where(user_id:session[:user_id])

	erb :profile
end

get '/sign-out' do
	session[:user_id]=nil
	redirect '/sign-in'
end

post '/post-process' do
	a = User.find(session[:user_id])
	Post.create(data:params[:content], author:(a.username), user_id:session[:user_id], movie_id:session[:cur_movie])
	redirect "/movie/#{session[:cur_movie]}"
end

post '/profile-post-process/:id' do
	a = User.find(session[:user_id])
	ProfilePosts.create(data:params[:content], author:(a.username), user_id:session[:user_id], profile_id:params[:id])
	redirect "/user/#{params[:id]}"
end

get '/movies' do
	@movie=Movie.all()
	@mlikes=MovieLikes.where(user_id:session[:user_id])
	if (@mlikes == nil)
		@mlikes = []
	end
	@plikes=PostLikes.where(user_id:session[:user_id])
	if (@plikes == nil)
		@plikes = []
	end
	current_user
	@profile=User.find(@current_user.id).profile
	erb :movies
end

get '/movie/:id' do
	if params[:id].blank?
		@movie = Movie.find(@movie_hash[:movie_id])
		session[:cur_movie] = @movie.id
	else
		@movie=Movie.find(params[:id])
		session[:cur_movie] = @movie.id
	end

	@mlikes=MovieLikes.where(user_id:session[:user_id])
	@plikes=PostLikes.where(user_id:session[:user_id])
	current_user
	@profile=User.find(@current_user.id).profile
	@liked_posts = []
	@liked_movies=[]

	PostLikes.where(user_id:session[:user_id]).each do |n| 
		@liked_posts.push(n.post_id)
	end

	MovieLikes.where(user_id:session[:user_id]).each do |t| 
		@liked_movies.push(t.movie_id)

	end	
	
	erb :movie
end

get '/plike/:id' do 
	PostLikes.create(user_id:session[:user_id], post_id:params[:id])
	redirect "/movie/#{session[:cur_movie]}"
end

get '/punlike/:id' do 
	a = PostLikes.where(user_id:session[:user_id], post_id:params[:id])
	PostLikes.destroy(a)
	redirect "/movie/#{session[:cur_movie]}"
end

get '/mlike/:id' do
	MovieLikes.create(user_id:session[:user_id], movie_id:params[:id])
	redirect "/movie/#{session[:cur_movie]}"
end

get '/munlike/:id' do
	b = MovieLikes.where(user_id:session[:user_id], movie_id:params[:id])
	MovieLikes.destroy(b)
	redirect "/movie/#{session[:cur_movie]}"
end
