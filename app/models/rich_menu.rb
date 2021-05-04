class RichMenu < ApplicationRecord
  belongs_to :account
  has_one :brand, through: :account
  has_one :market, through: :brand
  has_many :rich_menu_contents, foreign_key: :group_hash

  scope :search_by_account, -> (search_account) do
    return if search_account.blank?
    joins(:brand)
    .where('accounts.name LIKE ? OR brands.name LIKE ?', "%#{search_account}%", "%#{search_account}%")
  end

  scope :where_market_id, -> (market_id) do
    return if market_id.blank?
    joins(:brand)
    .where('brands.market_id = ?', market_id)
  end

  scope :fulltext_search_by_url, -> (search_url) do
    return if search_url.blank?
    url_match_sql = sanitize_sql_array([%!MATCH(lp_combined_urls.combined_url) AGAINST(? IN BOOLEAN MODE)!, "+#{search_url}"])
    group_hashes = RichMenuContent
      .joins("INNER JOIN lp_combined_urls ON rich_menu_contents.url_hash = lp_combined_urls.url_hash")
      .where(url_match_sql)
      .pluck(:group_hash)
    where(group_hash: group_hashes)
  end

  scope :order_by, -> (sort) do
    case sort
    when 'date_from' then
      order(date_from: "DESC")
    else
      order(date_from: "DESC")
    end
  end

  scope :where_is_favorite, -> (is_favorite) do
    return if is_favorite.blank?
    favorite_account_ids = User.current.favorites.pluck(:account_id)
    where(account_id: favorite_account_ids)
  end
end
