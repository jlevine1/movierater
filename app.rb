require 'sinatra'
require 'sinatra/activerecord'
require 'carrierwave'
require 'carrierwave/orm/activerecord'

configure(:development){set :database, "sqlite3:example3.sqlite3"}

require './models'
require 'bundler/setup'
require 'rack-flash'

set :sessions, true
use Rack::Flash, :sweep=>true

def current_user
	if session[:user_id]
		@current_user=User.find(session[:user_id])
	end
end
@movie_hash = {}
get '/' do
	redirect '/sign-in'
end

get '/sign-in' do
	erb :sign_in
end

post '/sign-in-process' do
	@user=User.find_by_username params[:username]
	if @user && @user.password==params[:password]
		flash[:message]="Success"
		session[:user_id]=@user.id
		redirect '/home'
	else
		flash[:message]="Failed"
		redirect '/sign-in'
	end
end

get '/sign-up' do
	erb :sign_up
end

post '/sign-up-process' do
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

get '/edit-profile' do
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
	redirect '/profile'
end

get '/add-movie' do
	erb :add_movie
end

post '/add-movie-process' do
	current_user
	Movie.create()
	@movie = Movie.last
	@movie.title=params[:movie_title]
	@movie.avatar=params[:movie_pic]
	@movie.rating=params[:stars]
	@movie.user_id= @current_user.id
	@movie.save
	redirect '/movies'
end

get '/delete-account' do
	User.destroy(session[:user_id])
	Profile.destroy(session[:user_id])
	redirect '/sign-in'
end

get '/user/:id' do
	@current_user=User.find(params[:id]);
	@current_profile=Profile.find_by_user_id(params[:id])
	erb :profile
end

get 'sign-out' do
	session[:user_id]=nil
	flash[:message]="Logged out"
	redirect '/sign-in'
end

post '/post-process' do
	a = User.find(session[:user_id])
	Post.create(data:params[:content], author:(a.username), user_id:session[:user_id])
	
	@movie_hash[:movie_id] = params[:movie_id]
	redirect '/movie/:id'
end

get '/profile' do
	@current_profile=Profile.find_by_user_id(session[:user_id])
	@current_user=User.find(session[:user_id])
	erb :profile
end

get '/home' do
	@current_user=User.find(session[:user_id])
	@profile=User.find(@current_user.id).profile
	erb :home
end

get '/movies' do
	@movie=Movie.all()
	@current_user=User.find(session[:user_id])
	erb :movies
end

get '/movie/:id' do
	if params[:id].blank?
		@movie = Movie.find(@movie_hash[:movie_id])
	else
		@movie=Movie.find(params[:id])
	end
	@current_user=User.find(session[:user_id])
	erb :movie
end











