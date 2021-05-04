class RichMenuForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  validates_inclusion_of :market_id, in: Market.pluck(:id), allow_blank: true
  validates_inclusion_of :sort, in: %w[date_from], allow_blank: true

  attribute :search_account, :string
  attribute :market_id, :integer
  attribute :search_url, :string
  attribute :start_date, :date
  attribute :end_date, :date
  attribute :sort, :string
  attribute :is_favorite, :boolean

  def search
    return RichMenu.none unless valid?

    self.start_date ||= '2021/02/01'.to_date
    self.end_date   ||= Date.today
    RichMenu
      .preload(:market)
      .where_is_favorite(is_favorite)
      .search_by_account(search_account)
      .where_market_id(market_id)
      .fulltext_search_by_url(search_url)
      .where(date_from: start_date..end_date)
      .order_by(sort)
  end

  def search_in_accounts_show(account_id)
    return RichMenu.none unless valid?

    self.start_date ||= '2021/02/01'.to_date
    self.end_date   ||= Date.today

    Account.find(account_id)
           .rich_menus
           .fulltext_search_by_url(search_url)
           .where(date_from: start_date..end_date)
           .order_by(sort)
  end
end
