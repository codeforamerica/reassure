require 'sinatra'
require 'sinatra/activerecord'
require 'koala'
require './environments'
require 'pry'

class Answer < ActiveRecord::Base  
  validates :facebook_id, presence: true, uniqueness: true
  validates :answer, :inclusion => { :in => [true, false] }
end

class Reassure < Sinatra::Base
  use Rack::Session::Cookie, secret: ENV["SECRET"]  

  before do
    @APP_ID = ENV["FACEBOOK_APP_ID"]
    @APP_SECRET = ENV["FACEBOOK_APP_SECRET"]
    @MINIMUM_SAMPLE_SIZE = 1

    if session['access_token']
      # Cache this or put it in the session?
      @logged_in = true
      @graph = Koala::Facebook::GraphAPI.new(session["access_token"])
      facebook_id = @graph.get_object("me")['id']
      @user_answer = Answer.find_by(facebook_id: facebook_id)
    end
  end

  get '/' do
    if @logged_in
      
      if @user_answer.nil?
        erb :question
      else
        redirect '/answer'
      end

    else
      erb :login
    end
  end

  get '/login' do
    # generate a new oauth object with your app data and your callback url
    session['oauth'] = Koala::Facebook::OAuth.new(@APP_ID, @APP_SECRET, "#{request.base_url}/callback")
    # redirect to facebook to get your code
    redirect session['oauth'].url_for_oauth_code(:permissions => "user_friends")
  end

  get '/logout' do
    session['oauth'] = nil
    session['access_token'] = nil
    redirect '/'
  end

  # method to handle the redirect from facebook back to you
  get '/callback' do
    # get the access token from facebook with your code
    session['access_token'] = session['oauth'].get_access_token(params[:code])
    redirect '/'
  end

  post '/question' do
    # save submitted question data
    @answer = Answer.new('facebook_id' => session['facebok_id'],
                          'answer' => params[:answer])

    if @answer.save
      redirect '/answer'
    else
      # Add a flash here
      redirect '/'
    end
  end

  get '/answer' do
    friends = @graph.get_connections("me", "friends")
    if friends.count < @MINIMUM_SAMPLE_SIZE
      erb :notenough
    else
      friends_answers = Answer.where("facebook_id IN (?)", friends).to_a
      friends_who_said_yes = friends_answers.select { |a| a.answer? }
      @percent_friends_who_said_yes = (friends_who_said_yes.count.to_f / friends.count).round(2)
      erb :answer
    end
  end
end