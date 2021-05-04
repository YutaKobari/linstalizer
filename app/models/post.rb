class Post < ApplicationRecord
  belongs_to :account
  has_one    :brand, through: :account
  has_one    :market, through: :brand
  has_many   :post_contents
  has_many   :post_like_counts
  has_many   :post_retweet_counts
  has_many   :post_hash_tags
  has_many   :hash_tags, through: :post_hash_tags, primary_key: :post_id
  belongs_to :landing_page, optional: true, primary_key: :url_hash, foreign_key: :url_hash

  scope :where_market_id, -> (market_id) do
    return if market_id.blank?
    joins(:brand)
    .where('brands.market_id = ?', market_id)
  end

  scope :fulltext_search_by_text, -> (search_text) do
    return if search_text.blank?
    where(sanitize_sql_array([%!MATCH(`text`) AGAINST(? in boolean mode)!, "+#{search_text}"]))
  end

  scope :search_by_account, -> (search_account) do
    return if search_account.blank?
    joins(:brand)
    .where('accounts.name LIKE ? OR brands.name LIKE ?', "%#{search_account}%", "%#{search_account}%")
  end

  scope :search_by_hash_tag, -> (search_hash_tag) do
    return if search_hash_tag.blank?
    where(id: HashTag.where(name: search_hash_tag).map{|a| a.posts.pluck(:id)}.flatten)
  end

  scope :fulltext_search_by_url, -> (search_url) do
    return if search_url.blank?
    joins("INNER JOIN lp_combined_urls ON posts.url_hash = lp_combined_urls.url_hash")
    .where(sanitize_sql_array([%!MATCH(lp_combined_urls.combined_url) AGAINST(? IN BOOLEAN MODE)!, "+#{search_url}"]))
  end

  scope :where_media, -> (media) do
    return if media.blank?
    where(media: media)
  end

  scope :where_post_type, -> (post_type) do
    return if post_type.blank?
    where(post_type: post_type)
  end

  scope :where_media_post_types, -> (media_post_types) do
    return if media_post_types.blank?
    condition_sql = media_post_types.inject('') do |sql, media_post_type|
      media = media_post_type[:media]
      post_type = media_post_type[:post_type]
      sql + sanitize_sql_array(["(media = ? AND post_type = ?) OR", media, post_type])
    end.chop.chop
    where(condition_sql)
  end

  scope :between_posted_on, -> (first_day, last_day) do
    return if first_day.blank? || last_day.blank?
    sql = Post.sanitize_sql_array(["posted_on BETWEEN ? AND ?", first_day, last_day])
    where(sql)
  end

  scope :order_by, -> (sort) do
    case sort
    when 'like' then
      order(like_count: "DESC")
    when 'retweet' then
      order(retweet_count: "DESC")
    when 'posted_at' then
      order(posted_at: "DESC")
    else
      order(posted_at: "DESC")
    end
  end

  scope :where_is_favorite, -> (is_favorite) do
    return if is_favorite.blank?
    favorite_account_ids = User.current.favorites.pluck(:account_id)
    where(account_id: favorite_account_ids)
  end

  scope :between_posted_at, -> (start_date, end_date) do
    where(posted_at: start_date..(end_date + 1.day)) # date型で同日を指定するとなにもヒットしないため
  end

  def make_like_chart_data
    chart_data = { labels: [], data: [] }
    post_like_counts.order(datetime: 'ASC').each do |like_count|
      chart_data[:labels].push I18n.l(like_count.datetime, format: :short)
      chart_data[:data].push like_count.like_count
    end
    chart_data
  end

  def make_retweet_chart_data
    chart_data = { labels: [], data: [] }
    post_retweet_counts.order(datetime: 'ASC').each do |retweet_count|
      chart_data[:labels].push I18n.l(retweet_count.datetime, format: :short)
      chart_data[:data].push retweet_count.retweet_count
    end
    chart_data
  end

  def self.fetch_heatmap_data(args)
    select("day, hour, post_type, media, COUNT(*) as post_count")
    .where(posted_at: args[:aggregated_from]..args[:aggregated_to])
    .where_media_post_types(args[:media_post_types])
    .group(:day, :hour, :post_type, :media)
  end
end
