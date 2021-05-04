class AccountForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  validates_inclusion_of :market_id, in: Market.pluck(:id), allow_blank: true
  validates_inclusion_of :media, in: %w(LINE Instagram Twitter Facebook), allow_blank: true
  validates_inclusion_of :sort , in: %w(follower_increment post_increment total_reaction_increment follower_increment_rate max_posted_at), allow_blank: true

  attribute :search_account , :string
  attribute :market_id      , :integer
  attribute :media          , :string
  attribute :aggregated_from, :date
  attribute :aggregated_to  , :date
  attribute :sort           , :string
  attribute :is_favorite    , :boolean

  def search
    return Account.none unless self.valid?
    self.aggregated_to ||= DailyAccountEngagement.order('date DESC').first&.date

    Account
      .where_is_favorite(is_favorite)
      .search_by_account(search_account)
      .where_market_id(market_id)
      .where_media(media)
      .select_engagement_increment(aggregated_from, aggregated_to)
      .order_by(sort)
  end
end
