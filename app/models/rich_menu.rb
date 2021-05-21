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

  # offset位置からsize件取得する
  def self.fetch_csv_row_post(relation, offset, size)
    select_columns = <<~EOS
      #{table_name}.account_id,
      accounts.name as account_name,
      brands.id,
      brands.name as brand_name,
      markets.name as market_name,
      #{table_name}.content_url,
      #{table_name}.date_from,
      #{table_name}.date_to
    EOS
    # size件分取得するSQLを発行
    records = relation.joins(:market)
                      .select(select_columns)
                      .offset(offset)
                      .take(size)
    csv_array = records.map do |rich_menu|
      [
        rich_menu.account_name,
        rich_menu.brand_name,
        rich_menu.market_name,
        rich_menu.content_url,
        rich_menu.date_from,
        rich_menu.date_to || '表示中'
      ]
    end
  end
end
