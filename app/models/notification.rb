class Notification < ApplicationRecord
  def self.active_notifications
    Notification.where(is_active: 1).order(posted_at: 'desc')
  end
end
