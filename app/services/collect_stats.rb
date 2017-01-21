require 'open-uri'

class CollectStats
  ICECAST_URL = "#{ENV['ICECAST_STATS_HOST']}/admin/listmounts?with_listeners"
  def initialize radio
    @redis = Redis.current
    @radio = radio
  end

  def perform
    current_connected_ids = []
    doc = Nokogiri::HTML(open(ICECAST_URL, http_basic_authentication: ["admin", "hackme"]))
    doc.xpath("//source[@mount=\"/#{@radio.name}.mp3\"]/listener").each do |listener|
      # ip = listener.xpath("//ip").text
      ip = listener.children.select{|n| n.name == "ip"}.first.text
      icecast_listener_id = listener.children.select{|n| n.name == "id"}.first.text.to_i
      current_connected_ids << icecast_listener_id
      # store current listeners in redis
      # {id: 3, start_at:}
      unless is_connected? icecast_listener_id
        # listen = @redis.hget @radio.listeners_key, icecast_listener_id
      #else
        start_at = Time.now
        Listen.create radio: @radio, ip_address: ip, icecast_listener_id: icecast_listener_id, start_at: start_at
        @redis.hset @radio.listeners_key, icecast_listener_id, start_at
      end
    end
    end_at = Time.now
    @redis.hgetall(@radio.listeners_key).each do |id, start_at|
      unless current_connected_ids.include? id.to_i
        listen = @radio.listens.find_by(icecast_listener_id: id.to_i)
        if listen
          listen.update end_at: end_at
        end
        @redis.hdel @radio.listeners_key, id
      end
    end
  end

  private
  def is_connected? id
    listen = @redis.hget @radio.listeners_key, id
    !listen.blank?
  end
end
