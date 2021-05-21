class Account < ApplicationRecord
  belongs_to :brand
  has_one    :company, through: :brand
  has_one    :market, through: :brand
  has_many   :posts
  has_many   :talk_posts
  has_many   :talk_post_contents
  has_many   :daily_account_engagements
  has_many   :daily_account_informations
  has_many   :rich_menus
  has_many   :favorites

  scope :search_by_account, -> (search_account) do
    return preload(:company) if search_account.blank?
    joins(:company)
    .where('accounts.name LIKE ? OR brands.name LIKE ? OR companies.name LIKE ?', "%#{search_account}%", "%#{search_account}%", "%#{search_account}%")
  end

  scope :where_market_id, -> (market_id) do
    return if market_id.blank?
    joins(:brand)
    .where('brands.market_id = ?', market_id)
  end

  scope :where_media, -> (media) do
    return if media.blank?
    where(media: media)
  end

  scope :select_engagement_increment, -> (aggregated_from, aggregated_to) do
    if aggregated_from == "2000/01/01".to_date
      select(<<-EOS
        accounts.*,
        (aggre_to.follower) follower_increment,
        (aggre_to.post_count) post_increment,
        (aggre_to.total_reaction) total_reaction_increment,
        '-' follower_increment_rate,
        '-' total_reaction_increment_rate
        EOS
      ).joins(inner_query(aggregated_to, "aggre_to"))
    else
      select(<<-EOS
        accounts.*,
        (aggre_to.follower - aggre_from.follower) follower_increment,
        (aggre_to.post_count - aggre_from.post_count) post_increment,
        (aggre_to.total_reaction - aggre_from.total_reaction) total_reaction_increment,
        ((aggre_to.follower - aggre_from.follower) / aggre_from.follower * 100) follower_increment_rate,
        ((aggre_to.total_reaction - aggre_from.total_reaction) / aggre_from.total_reaction * 100) total_reaction_increment_rate
        EOS
      ).joins(inner_query(aggregated_from, "aggre_from")).joins(inner_query(aggregated_to, "aggre_to"))
      # .joins("post ON post.account_id = account.id AND post.posted_at BETWEEN #{aggregated_from} AND #{aggregated_to}") ここでjoinしないと最新投稿日が出せない（バッチでテーブルに入れてしまうというのもあり）。
    end
  end

  scope :order_by, -> (sort) do
    case sort
    when 'post_increment' then
      order("post_increment DESC")
    when 'total_reaction_increment' then
      order("total_reaction_increment DESC")
    when 'follower_increment_rate' then
      order("follower_increment_rate DESC")
    when 'total_reaction_increment_rate' then
      order("total_reaction_increment_rate DESC")
    when 'max_posted_at' then
      order("max_posted_at DESC")
    else
      order("follower_increment DESC")
    end
  end

  scope :where_is_favorite, -> (is_favorite) do
    return if is_favorite.blank?
    favorite_account_ids = User.current.favorites.pluck(:account_id)
    where(id: favorite_account_ids)
  end

  def fetch_follower_per_date(follower_transition_params, relative: false, increment: false )
    #初期値は30日間(フォームのplaceholderと一致させる必要あり)
    first_day = follower_transition_params[:graph_aggregated_from]&.to_date || 29.days.ago.to_date
    last_day = follower_transition_params[:graph_aggregated_to]&.to_date || Date.today
    follower_data = daily_account_engagements
      .between_date(first_day, last_day)
      .order(date: :asc)
      .group(:date)
      .map{ |dae| {date: dae.date, value: dae.follower} }

    # 歯抜けている日付はNILで付加する
    first_day.upto(last_day) do |date|
      unless follower_data.any?{|d| d[:date] == date}
        follower_data.unshift({date: date, value: NIL})
      end
    end
    
    if increment # 前日からの増加の場合
      follower_data.sort!{|a, b| a[:date] <=> b[:date]}
      base = daily_account_engagements.find_by(date: first_day - 1)&.follower
      if relative # 比率で表す場合
        follower_data.map {|d|
          follower = (d[:value].nil? or base.nil?)? nil : (d[:value] - base).to_f * 100 / base
          base = d[:value]
          {date: d[:date].to_s, value: follower}
        }
      else # 絶対数で表す場合
        follower_data.map {|d|
          follower = (d[:value].nil? or base.nil?)? nil : (d[:value] - base)
          base = d[:value]
          {date: d[:date].to_s, value: follower}
        }
      end
    else # 通常のデータの場合
      follower_data.sort!{|a, b| a[:date] <=> b[:date]}
      base = follower_data.first[:value]
      if relative # 比率で表す場合
        follower_data.map {|d|
          follower = (d[:value].nil? or base.nil?)? nil : d[:value].to_f * 100 / base
          {date: d[:date].to_s, value: follower}
        }
      else # 絶対数で表す場合
        follower_data.map {|d| {date: d[:date].to_s, value: d[:value]}}
      end
    end   
  end

  def latest_engagement
    return @latest_engagement if @latest_engagement
    latest_date = daily_account_engagements.pluck(:date).max
    @latest_engagement = daily_account_engagements.find_by(date: latest_date)
  end

  def latest_introduction
    latest_date = daily_account_informations.pluck(:date).max
    daily_account_informations.find_by(date: latest_date, key: 'introduction')&.value
  end

  def posts_per_date(follower_transition_params)
    first_day = follower_transition_params[:graph_aggregated_from]&.to_date || 29.days.ago.to_date
    last_day = follower_transition_params[:graph_aggregated_to]&.to_date || Date.today
    posts_per_date = posts
      .between_posted_on(first_day, last_day)
      .group(:media, :posted_on)
      .select("media, posted_on, count(*) as post_count")

    posts_per_date.map do |r|
      {
        media:     r.media,
        posted_on: r.posted_on,
        sum:       r.post_count,
      }
    end.to_json
  end

  def talk_posts_per_date(follower_transition_params)
    first_day = follower_transition_params[:graph_aggregated_from]&.to_date || 29.days.ago.to_date
    last_day = follower_transition_params[:graph_aggregated_to]&.to_date || Date.today
    talk_posts_per_date = talk_posts
      .between_posted_on(first_day, last_day)
      .group(:posted_on)
      .select("'LINE' as media, posted_on, count(*) as post_count")

    talk_posts_per_date.map do |r|
      {
        media:     r.media,
        posted_on: r.posted_on,
        sum:       r.post_count,
      }
    end.to_json
  end

  def fetch_posts(post_params)
    current_tab = post_params[:current_tab]
    # 現在のタブがタイムラインタブでない場合は期間のみで絞り込みを行う
    params = if current_tab.nil?
               post_params.except(:current_tab)
             else
               post_params.slice(:start_date, :end_date)
             end
    PostForm.new(params)
            .search_in_accounts_show(self.id)
  end

  def fetch_talk_posts(talk_post_params)
    current_tab = talk_post_params[:current_tab]
    # 現在のタブがトークタブでない場合は期間のみで絞り込みを行う
    params = if current_tab == 'talk'
               talk_post_params.except(:current_tab)
             else
               talk_post_params.slice(:start_date, :end_date)
             end
    TalkPostForm.new(params)
                .search_in_accounts_show(self.id)
  end

  def fetch_rich_menus(rich_menu_params)
    current_tab = rich_menu_params[:current_tab]
    params = rich_menu_params.except(:current_tab)
    if current_tab == 'rich_menu'
      RichMenuForm.new(params)
                  .search_in_accounts_show(self.id)
    else
      # 現在のタブがリッチメニュータブでない場合は期間のみで絞り込みを行う
      Account.find(self.id)
             .rich_menus
             .where(date_from: '2021/02/01'.to_date..Date.today)
             .order_by('date_from')
    end
  end


  private

  def self.inner_query(date, sub_query_name)
    <<-EOS
      LEFT OUTER JOIN (
        SELECT dae.* FROM daily_account_engagements dae
        WHERE dae.date = '#{date}'
        ) AS #{sub_query_name}
      ON #{sub_query_name}.account_id = accounts.id
    EOS
  end

  def follower_transition_month_to_span(follower_transition_month)
    follower_transition_month = "#{Date.today.year}-#{Date.today.month}"if follower_transition_month.blank?
    year, month = follower_transition_month.split("-").map(&:to_i)
    first_day = Date.new(year,month, 1)
    last_day = [Date.today, first_day.end_of_month].min
    [first_day, last_day]
  end

  # offset位置からsize件取得する
  def self.fetch_csv_row_post(relation, offset, size)
    select_columns = <<~EOS
      brands.name as brand_name,
      markets.name as market_name,
      companies.name as company_name
    EOS
    # size件分取得するSQLを発行
    records = relation.joins(:market, :company)
                      .select(select_columns)
                      .offset(offset)
                      .take(size)
    csv_array = records.map do |account|
      [
        account.media,
        account.name,
        account.screen_name,
        account.brand_name,
        account.market_name,
        account.company_name,
        account.max_posted_at,
        account.post_increment,
        account.total_reaction_increment,
        account.follower_increment,
        account.follower_increment_rate,
        account.total_reaction_increment_rate
      ]
    end
  end
end
