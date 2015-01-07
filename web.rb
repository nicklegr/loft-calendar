require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/url_for'
require 'haml'
require './db'

get '/' do
  haml :index
end

get '/stats' do
  haml :stats
end
