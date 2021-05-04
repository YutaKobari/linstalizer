class LpForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :search_text    , :string
  attribute :market_id      , :integer
  attribute :search_url     , :string
  attribute :start_date     , :date
  attribute :end_date       , :date
  attribute :sort           , :string
  attribute :is_favorite    , :boolean

  def search
    return LandingPage.none unless self.valid?
    self.start_date  ||=  "2021/02/01".to_date
    self.end_date    ||=  LandingPage.all.order(max_published_at: "DESC").first&.max_published_at

    LandingPage
      .preload(:posts)
      .where_is_favorite(is_favorite)
      .select_post_counts
      .where_market_id(market_id)
      .fulltext_search_by_text(search_text)
      .fulltext_search_by_url(search_url)
      .between_max_published_at(start_date, end_date)
      .order_by(sort)
  end
end
