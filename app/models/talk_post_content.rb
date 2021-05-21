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


  scope :between_posted_hour, -> (hour_start, hour_end) do
    return if hour_start.blank? || hour_end.blank?
      joins(:talk_post)
      .where('talk_posts.hour BETWEEN ? AND ?', hour_start, hour_end)
  end
  
  # offset位置からsize件取得する
  def self.fetch_csv_row_post(relation, offset, size)
    select_columns = <<~EOS
      #{table_name}.account_id,
      accounts.name as account_name,
      #{table_name}.brand_id,
      brands.name as brand_name,
      markets.name as market_name,
      #{table_name}.post_type,
      #{table_name}.content_url,
      #{table_name}.video_url,
      #{table_name}.text,
      #{table_name}.posted_at,
      #{table_name}.landing_page_url,
      #{table_name}.talk_group_hash
    EOS
    # size件分取得するSQLを発行
    records = relation.joins(:market)
                      .select(select_columns)
                      .offset(offset)
                      .take(size)
    # できればtalk_post_helperと共通のハッシュを用いたい
    display_hash = { 'text' => 'テキストメッセージ', 'image' => '画像メッセージ', 'video' => '動画メッセージ', 'image_map' => 'イメージマップ',
      'carousel' => 'カルーセル' }
    csv_array = records.map do |talk_post|
      [
        talk_post.account_name,
        talk_post.brand_name,
        talk_post.market_name,
        display_hash[talk_post.post_type],
        case talk_post.post_type
        when 'text'
          talk_post.text
        when 'video'
          talk_post.video_url
        else
          talk_post.content_url
        end,
        talk_post.posted_at,
        talk_post.landing_page_url
      ]
    end
  end
end
