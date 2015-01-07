require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/url_for'
require 'haml'
require 'icalendar'
require 'active_support'
require 'active_support/core_ext'
require './db'

configure do
  mime_type :ics, "text/calendar"
end

get '/' do
  haml :index
end

get '/stats' do
  haml :stats
end

get '/*.ics', :provides => [ :ics ] do |live_house|
  cal = Icalendar::Calendar.new

  Event
    .where("live_house" => live_house)
    .where(:open_at.gte => Time.now.beginning_of_month)
    .each do |record|

    cal.event do |e|
      e.dtstart = record.open_at
      e.summary = record.title
      e.description = record.url
    end
  end

  cal.to_ical
end
