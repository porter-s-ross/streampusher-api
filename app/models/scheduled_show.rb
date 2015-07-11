class ScheduledShow < ActiveRecord::Base
  belongs_to :radio
  belongs_to :show
  belongs_to :playlist

  validates_presence_of :start_at, :end_at
  validates_presence_of :show_id

  alias_attribute :start, :start_at
  alias_attribute :end, :end_at

  after_save :persist_to_redis

  # TODO
  # validate :time_is_in_15_min_intervals

  def title
    self.show.title
  end

  def dj
    self.show.dj
  end

  def image_url
    self.show.image.url(:thumb)
  end

  def schedule_cannot_conflict
    self.radio.scheduled_shows.where.not(id: id).each do |show|
      if end_at > show.start_at && start_at < show.end_at
        errors.add(:time, " conflict detected with show '#{show.user.username} - #{show.title}'. Please choose a different time.")
      end
    end
  end

  def time_keys
    cur_time = self.start_at.utc
    time_keys = []
    while cur_time < self.end_at.utc do
      date = cur_time.strftime("%m%d%Y")
      hours_mins = cur_time.strftime("%Hh%Mm")
      time_keys << "#{date}:#{hours_mins}"
      cur_time = cur_time + 15.minutes
    end

    time_keys
  end

  def redis_keys
    time_keys.map{|key| "#{self.radio.name}:schedule:#{key}"}
  end

  def persist_to_redis redis=Redis.current
    redis_keys.each do |key|
      redis.set key, self.show.playlist.redis_key
    end
  end
end
