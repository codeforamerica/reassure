require 'sinatra'
require 'koala'
require 'pry'

class Reassure < Sinatra::Base
  use Rack::Session::Cookie, secret: ENV["SECRET"]  

  before do
    @APP_ID = ENV["FACEBOOK_APP_ID"]
    @APP_SECRET = ENV["FACEBOOK_APP_SECRET"]
  end

  get '/' do
    if session['access_token']
      @graph = Koala::Facebook::GraphAPI.new(session["access_token"])
      profile = @graph.get_object("me")
      friends_on_reassure = @graph.get_connections("me", "friends")
      "#{friends}
      You are logged in! <a href='/logout'>Logout</a>"

      # publish to your wall (if you have the permissions)
      # @graph.put_wall_post("I'm posting from my new cool app!")
    else
      '<a href="/login">Login</a>'
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

  #method to handle the redirect from facebook back to you
  get '/callback' do
    #get the access token from facebook with your code
    session['access_token'] = session['oauth'].get_access_token(params[:code])
    redirect '/'
  end
end