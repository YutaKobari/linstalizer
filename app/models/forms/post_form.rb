class PostForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  # TODO: mediaに応じて選択可能なpost_typeが決まる。2つの組み合わせでのバリデーションもかけられると尚良い。
  validates_inclusion_of :market_id, in: Market.pluck(:id), allow_blank: true
  validates_inclusion_of :media, in: %w[LINE Instagram Twitter Facebook], allow_blank: true
  validates_inclusion_of :post_type, in: %w[feed reel story tweet retweet normal_post], allow_blank: true
  validates_inclusion_of :sort, in: %w[like retweet posted_at], allow_blank: true

  attribute :search_text, :string
  attribute :search_account, :string
  attribute :market_id      , :integer
  attribute :search_hash_tag, :string
  attribute :search_url, :string
  attribute :media, :string
  attribute :post_type, :string
  attribute :start_date, :date
  attribute :end_date, :date
  attribute :sort, :string
  attribute :is_favorite, :boolean

  def search
    return Post.none unless valid?
    self.start_date ||= '2021/02/01'.to_date # TODO: 顧客の登録日に合わせてstarted_atにデフォルト値を設定予定。
    self.end_date   ||= Date.today

    Post
      .preload(:market)
      .fulltext_search_by_text(search_text)
      .search_by_account(search_account)
      .where_market_id(market_id)
      .search_by_hash_tag(search_hash_tag)
      .fulltext_search_by_url(search_url)
      .where_is_favorite(is_favorite)
      .where_media(media)
      .between_posted_at(start_date, end_date)
      .where_post_type(post_type)
      .order_by(sort)
  end

  def search_in_lp_show(id)
    self.start_date ||= '2021/02/01'.to_date # TODO: 顧客の登録日に合わせてstarted_atにデフォルト値を設定予定。
    self.end_date   ||= Date.today

    LandingPage.find_by(id: id)
               .posts
               .fulltext_search_by_text(search_text)
               .search_by_hash_tag(search_hash_tag)
               .where_media(media)
               .between_posted_at(start_date, end_date)
               .where_post_type(post_type)
               .order_by(sort)
  end

  def search_in_brands_show(id)
    self.start_date ||= '2021/02/01'.to_date # TODO: 顧客の登録日に合わせてstarted_atにデフォルト値を設定予定。
    self.end_date   ||= Date.today

    Brand.find_by(id: id)
         .posts
         .fulltext_search_by_text(search_text)
         .search_by_hash_tag(search_hash_tag)
         .fulltext_search_by_url(search_url)
         .where_media(media)
         .between_posted_at(start_date, end_date)
         .where_post_type(post_type)
         .order_by(sort)
  end

  def search_in_accounts_show(id)
    #return Post.none unless valid?
    self.start_date ||= '2021/02/01'.to_date # TODO: 顧客の登録日に合わせてstarted_atにデフォルト値を設定予定。
    self.end_date   ||= Date.today

    Account.find_by(id: id)
           .posts
           .fulltext_search_by_text(search_text)
           .search_by_hash_tag(search_hash_tag)
           .fulltext_search_by_url(search_url)
           .between_posted_at(start_date, end_date)
           .where_post_type(post_type)
           .order_by(sort)
  end
end
