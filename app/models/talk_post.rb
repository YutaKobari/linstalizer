class TalkPost < ApplicationRecord
  belongs_to :account
  has_one :brand, through: :account
  belongs_to :landing_page, optional: true
  has_many :talk_post_contents, foreign_key: :talk_group_hash, primary_key: :talk_group_hash

  scope :between_posted_on, -> (first_day, last_day) do
    return if first_day.blank? || last_day.blank?
    sql = Post.sanitize_sql_array(["posted_on BETWEEN ? AND ?", first_day, last_day])
    where(sql)
  end

  def self.fetch_heatmap_data(args)
    select("day, hour, 'talk_post' as post_type, 'LINE' as media, COUNT(*) as post_count")
    .where(posted_at: args[:aggregated_from]..args[:aggregated_to])
    .group(:day, :hour)
  end
end
