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
  @calendars = [
    { :id => "plusone", :name => "ロフトプラスワン", :gcal_id => "ddakjciduejju8u45g3mo02j7nmo720h" },
    { :id => "naked", :name => "ネイキッドロフト", :gcal_id => "55chha213nm8gflc9bds1fhmah22u0ak" },
    { :id => "lofta", :name => "阿佐ヶ谷ロフトA", :gcal_id => "ofkhgdcg5jnqgq1la74a8u9hh8p5c6o7" },
    { :id => "loft", :name => "新宿ロフト", :gcal_id => "vkutn2iash0t80qr02jj6u107lsvk479" },
    { :id => "shelter", :name => "下北沢シェルター", :gcal_id => "t7mihse06ak6svbfm96csc8ssee1dfvs" },
    { :id => "west", :name => "プラスワンWest", :gcal_id => "3c1mdb267bgs432oge704s6p8bb0rj61" },
    { :id => "broadcast", :name => "ロフトチャンネル", :gcal_id => "o86lgu3e3fanc82n7la5p62bcgv1ac24" },
  ]

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

  cal.append_custom_property("X-WR-CALNAME", name)
  cal.append_custom_property("X-WR-TIMEZONE", "Asia/Tokyo")
  cal.append_custom_property("X-WR-CALDESC", name)

  cal.timezone do |t|
    t.tzid = 'Asia/Tokyo'
    t.standard do |s|
      s.tzoffsetfrom = '+0900'
      s.tzoffsetto   = '+0900'
      s.tzname       = 'JST'
      s.dtstart      = '19700101T000000'
    end
  end

  Event
    .where("live_house" => live_house)
    .where(:open_at.gte => Time.now.beginning_of_month)
    .each do |record|

    cal.event do |e|
      e.dtstart = Icalendar::Values::DateTime.new(record.open_at, { 'TZID' => 'Asia/Tokyo' })
      e.summary = record.title
      e.description = record.url + "\n\n" + record.description
    end
  end

  cal.publish
  cal.to_ical
end
