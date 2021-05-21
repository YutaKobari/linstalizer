class TalkPostForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  validates_inclusion_of :market_id, in: Market.pluck(:id), allow_blank: true
  validates_inclusion_of :post_type, in: %w[text stamp image video image_map carousel], allow_blank: true # TODO: 項目追加、修正、どこかで一元管理したい

  attribute :search_text,     :string
  attribute :search_account,  :string
  attribute :search_url,      :string
  attribute :market_id,       :integer
  attribute :post_type,       :string
  attribute :start_date,      :date
  attribute :end_date,        :date
  attribute :hour_start,      :integer
  attribute :hour_end,        :integer
  attribute :is_favorite,     :boolean

  def search
    return TalkPost.none unless valid?

    self.start_date ||= '2021/02/01'.to_date
    self.end_date   ||= Date.today

    TalkPostContent
      .preload(:market)
      .preload(:talk_post)
      .where_is_favorite(is_favorite)
      .fulltext_search_by_text(search_text)
      .search_by_account(search_account)
      .where_market_id(market_id)
      .fulltext_search_by_url(search_url)
      .between_posted_at(start_date, end_date)
      .between_posted_hour(hour_start, hour_end)
      .where_post_type(post_type)
      .order_by_posted
      .group(:talk_group_hash)
  end

  def search_in_accounts_show(id)
    return TalkPost.none unless valid?

    self.start_date ||= '2021/02/01'.to_date
    self.end_date   ||= Date.today

    Account.find_by(id: id)
           .talk_post_contents
           .fulltext_search_by_text(search_text)
           .fulltext_search_by_url(search_url)
           .between_posted_at(start_date, end_date)
           .between_posted_hour(hour_start, hour_end)
           .where_post_type(post_type)
           .order_by_posted
           .group(:talk_group_hash)
  end

  # 普通のsearchメソッドからgroup_byを除いたもの
  def search_for_csvdl
    return TalkPost.none unless valid?

    self.start_date ||= '2021/02/01'.to_date
    self.end_date   ||= Date.today

    TalkPostContent
      .preload(:market)
      .preload(:talk_post)
      .where_is_favorite(is_favorite)
      .fulltext_search_by_text(search_text)
      .search_by_account(search_account)
      .where_market_id(market_id)
      .fulltext_search_by_url(search_url)
      .between_posted_at(start_date, end_date)
      .where_post_type(post_type)
      .order_by_posted
  end
end
