#!ruby -Ku
# coding: utf-8

require 'pp'
require './db'
require_relative 'loft'

class Watch
  def start
    loop do
      begin
        pp Loft.monthly_schedule("plusone", Time.now)
      rescue => e
        # 不明なエラーのときも、落ちずに動き続ける
        puts "#{e} (#{e.class})"
        puts e.backtrace

        sleep 10
      end
    end
  end
end

watcher = Watch.new
watcher.start
