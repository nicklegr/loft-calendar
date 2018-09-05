# coding: utf-8

require 'mongoid'

class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  field :event_id, type: Integer
  field :live_house, type: String
  field :title, type: String
  field :open_at, type: Time
  field :start_at, type: Time
  field :description, type: String
  field :url, type: String

  index({ event_id: 1 }, { unique: true, name: "event_id_index" })
  index({ live_house: 1 }, { name: "live_house_index" })
  index({ open_at: 1 }, { name: "open_at_index" })
end

Mongoid.configure do |config|
  config.sessions = { default: { database: 'loft', hosts: [ 'mongodb:27017' ] }}
end

Event.create_indexes
