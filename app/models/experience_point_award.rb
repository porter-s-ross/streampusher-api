class ExperiencePointAward < ApplicationRecord
  belongs_to :user

  after_save :maybe_level_up
  after_save :send_notification

  enum award_type: [
    :chat_lurker, # lurking in chat
    :music_enjoyer, # listening to stream or podcasts
    :textbox_poster, # posting chats
    :uploaderer, # uploading podcast
    :radio_enthusiast, # scheduling show
    :fruit_maniac, # clicking fruit buttons
    :streaming_streamer, # streaming live
  ]

  private
  def maybe_level_up
    self.user.update experience_points: self.amount
    while self.user.should_level_up?
      if self.user.should_level_up?
        self.user.level_up!
      end
    end
  end

  def send_notification
    Notification.create! source: self, notification_type: "experience_point_award", user: self.user, send_to_chat: false
  end
end
