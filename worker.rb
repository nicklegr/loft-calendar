#!ruby -Ku

require 'pp'
require './db'

class Watch
  def start
    loop do
      begin
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
