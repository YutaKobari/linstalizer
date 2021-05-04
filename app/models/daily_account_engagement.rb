class DailyAccountEngagement < ApplicationRecord
  belongs_to :account

  scope :between_date, -> (first_day, last_day) do
    return if first_day.blank? || last_day.blank?
    where(self.sanitize_sql_array(["date BETWEEN ? AND ?", first_day, last_day]))
  end
end
