# coding: utf-8

require 'open-uri'
require 'nokogiri'
require 'active_support'
require 'active_support/core_ext'

class Loft
  LIVE_HOUSES = {
    "plusone" => "ロフトプラスワン",
    "loft" => "新宿ロフト",
    "shelter" => "下北沢シェルター",
    "naked" => "ネイキッドロフト",
    "lofta" => "阿佐ヶ谷ロフトA",
    "west" => "プラスワンWest",
    "broadcast" => "ロフトチャンネル",
  }

  def self.live_house_name(key)
    LIVE_HOUSES[key]
  end

  def self.all_events
    ret = []
    now = Time.now

    LIVE_HOUSES.keys.each do |live_house|
      for month_after in 0..2
        date = now.beginning_of_month + month_after.months
        ret += monthly_schedule(live_house, date).map do |e|
          e.update({ "live_house" => live_house })
        end

        sleep 1
      end
    end

    ret
  end

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

        base_time = Time.new(year.to_i, month.to_i, day.to_i)
        open_at = start_at = base_time
        time_text = event.at_css('p.time_text')
        if time_text
          m = time_text.inner_text.match(
            %r|OPEN\s+(?<open_hour>\d+):(?<open_min>\d+)\s+/\s+START\s+(?<start_hour>\d+):(?<start_min>\d+)|
            )

          if m
            if m["open_hour"] && m["open_min"]
              open_at = base_time + m["open_hour"].to_i.hours + m["open_min"].to_i.minutes
            end

            if m["start_hour"] && m["start_min"]
              start_at = base_time + m["start_hour"].to_i.hours + m["start_min"].to_i.minutes
            end
          end
        end

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
