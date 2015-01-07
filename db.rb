require 'mongoid'

class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  index({ created_at: 1 }, { name: "created_at_index" })
end

Mongoid.configure do |config|
  if ENV.key?('MONGODB_PORT_27017_TCP_ADDR')
    # for docker
    config.sessions = { default: { database: 'loft', hosts: [ "#{ENV['MONGODB_PORT_27017_TCP_ADDR']}:27017" ] }}
  else
    config.sessions = { default: { database: 'loft', hosts: [ 'localhost:27017' ] }}
  end
end

Event.create_indexes
