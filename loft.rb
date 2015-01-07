# coding: utf-8

require 'open-uri'
require 'nokogiri'
require 'active_support/core_ext'

class Loft
  def self.monthly_schedule(live_house, date)
    ret = []

    year = date.year.to_s
    month = date.strftime("%m")

    url = "http://www.loft-prj.co.jp/schedule/#{live_house}/date/#{year}/#{month}"
    html = open(url).read

    doc = Nokogiri::HTML(html)
    doc.css("table.timetable tr").each do |day_row|
      day = day_row.at_css("th.day > text()").to_s

      day_row.css("div.event").each do |event|
        title_link = event.at_css("h3 > a")
        url = title_link["href"]
        title = title_link.inner_text

        # 全ライブハウスでユニークな番号らしい
        event_id = url[%r|(\d+)/?$|, 1].to_i

        description = event.at_css('p.month_content').inner_text.strip

        m = event.at_css('p.time_text').inner_text.match(
          %r|OPEN\s+(?<open_hour>\d+):(?<open_min>\d+)\s+/\s+START\s+(?<start_hour>\d+):(?<start_min>\d+)|
          )

        open_at = Time.new(year.to_i, month.to_i, day.to_i) +
          m["open_hour"].to_i.hours +
          m["open_min"].to_i.minutes

        start_at = Time.new(year.to_i, month.to_i, day.to_i) +
          m["start_hour"].to_i.hours +
          m["start_min"].to_i.minutes

        # puts [day, url, title, event_id, open_at, start_at, description].join(' ')

        ret << {
          "event_id" => event_id,
          "url" => url,
          "title" => title,
          "open_at" => open_at,
          "start_at" => start_at,
          "description" => description,
        }
      end
    end

    ret
  end
end
