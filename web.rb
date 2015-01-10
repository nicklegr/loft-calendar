# coding: utf-8

require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/url_for'
require 'haml'
require 'icalendar'
require 'active_support'
require 'active_support/core_ext'
require_relative 'db'
require_relative 'loft'

configure do
  mime_type :ics, "text/calendar"
end

get '/' do
  haml :index
end

get '/stats' do
  @last_update = Event.desc(:updated_at).first.updated_at
  @event_count = Event.count()
  haml :stats
end

get '/*.ics', :provides => [ :ics ] do |live_house|
  name = Loft.live_house_name(live_house)
  halt(404) unless name

  cal = Icalendar::Calendar.new

  cal.append_custom_property('X-WR-CALNAME;VALUE=TEXT', name)

  Event
    .where("live_house" => live_house)
    .where(:open_at.gte => Time.now.beginning_of_month)
    .each do |record|

    cal.event do |e|
      e.dtstart = Icalendar::Values::DateTime.new(record.open_at, { 'TZID' => 'Asia/Tokyo' })
      e.summary = record.title
      e.description = record.url
    end
  end

  cal.publish
  cal.to_ical
end
