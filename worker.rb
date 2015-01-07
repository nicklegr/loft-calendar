#!ruby -Ku
# coding: utf-8

require 'pp'
require_relative 'db'
require_relative 'loft'

class Watch
  def start
    loop do
      begin
        Loft.all_events.each do |event|
          record = Event.find_or_initialize_by("event_id" => event["event_id"])
          record.update(event)
          record.save!
        end
      rescue => e
        # 不明なエラーのときも、落ちずに動き続ける
        puts "#{e} (#{e.class})"
        puts e.backtrace
      ensure
        sleep 3.hours
      end
    end
  end
end

watcher = Watch.new
watcher.start
