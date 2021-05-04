class TalkPostContent < ApplicationRecord
  belongs_to :account
  has_one :brand, through: :account
  has_one :market, through: :brand
  belongs_to :landing_page, optional: true
  belongs_to :talk_post, foreign_key: :talk_group_hash, primary_key: :talk_group_hash

  scope :where_market_id, -> (market_id) do
    return if market_id.blank?
    joins(:brand)
    .where('brands.market_id = ?', market_id)
  end

  scope :fulltext_search_by_text, -> (search_text) do
    return if search_text.blank?
    where(sanitize_sql_array([%!MATCH(`text`) AGAINST(? in boolean mode)!, "+#{search_text}"]))
  end

  scope :fulltext_search_by_url, -> (search_url) do
    return if search_url.blank?
    joins("INNER JOIN lp_combined_urls ON talk_post_contents.url_hash = lp_combined_urls.url_hash")
    .where(sanitize_sql_array([%!MATCH(lp_combined_urls.combined_url) AGAINST(? IN BOOLEAN MODE)!, "+#{search_url}"]))
  end

  scope :search_by_account, -> (search_account) do
    return if search_account.blank?
    joins(:brand)
    .where('accounts.name LIKE ? OR brands.name LIKE ?', "%#{search_account}%", "%#{search_account}%")
  end

  scope :between_posted_at, -> (start_date, end_date) do
    # indexを効率よく使うため、敢えてtalk_postsではなくtalk_post_contentsのposted_atで絞り込んでいる
    where(posted_at: start_date..(end_date + 1.day)) # date型で同日を指定すると何もヒットしないため
  end

  scope :where_post_type, -> (post_type) do
    return if post_type.blank?
    where(post_type: post_type)
  end

  scope :order_by_posted, -> () do
      order(posted_at: "DESC")
  end

  scope :where_is_favorite, -> (is_favorite) do
    return if is_favorite.blank?
    favorite_account_ids = User.current.favorites.pluck(:account_id)
    where(account_id: favorite_account_ids)
  end
end
