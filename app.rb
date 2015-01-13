require 'sinatra'

class Reassure < Sinatra::Base

  get '/' do
    erb :index
  end

end