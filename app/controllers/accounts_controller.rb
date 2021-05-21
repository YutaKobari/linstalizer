class AccountsController < ApplicationController

  def index
    @search_params = account_params
    account_form = AccountForm.new(account_params)
    @accounts = account_form.search.page(params[:page]).without_count.per(50)
    default_aggregated_to = DailyAccountEngagement.order('date DESC').first&.date || Date.yesterday
    @aggregated_from = params[:aggregated_from]&.to_date || default_aggregated_to - 6.days
    @aggregated_to = params[:aggregated_to]&.to_date || default_aggregated_to
  end

  def show
    @account = Account.find(params[:id])
    @talk_post_contents = @account.fetch_talk_posts(talk_post_params).page(params[:talk_post_page]).without_count.per(30) if @account.media == 'LINE'
    @posts = @account.fetch_posts(post_params)                       .page(params[:page]).without_count.per(30)
    @rich_menus = @account.fetch_rich_menus(rich_menu_params)        .page(params[:rich_menu_page]).without_count.per(30) if @account.media == 'LINE'
    @follower_per_date = @account.fetch_follower_per_date(follower_transition_params)
    @follower_per_date_rel = @account.fetch_follower_per_date(follower_transition_params, relative: true)
    @follower_increment_per_date = @account.fetch_follower_per_date(follower_transition_params, increment: true)
    @follower_increment_per_date_rel = @account.fetch_follower_per_date(follower_transition_params, relative: true, increment: true)
    @posts_per_date = @account.posts_per_date(follower_transition_params)
    @talk_posts_per_date = @account.talk_posts_per_date(follower_transition_params)
  end

  def csv_download
    account_form = AccountForm.new(account_params)
    relation = account_form.search
    search_results_to_csv(relation, 'accounts.csv')
  end

  private

  def account_params
    params.permit(
      :search_account,
      :market_id,
      :media,
      :aggregated_from,
      :aggregated_to,
      :sort,
      :is_favorite
    )
  end

  def follower_transition_params
    params.permit(
      :graph_aggregated_from,
      :graph_aggregated_to
    )
  end

  def post_params
    params.permit(
      :current_tab,
      :search_text,
      #:search_account,
      :search_hash_tag,
      :search_url,
      #:media,
      :post_type,
      :start_date,
      :end_date,
      :hour_start,
      :hour_end,
      :sort
    )
  end

  def talk_post_params
    params.permit(
      :current_tab,
      :search_text,
      #:search_account,
      :search_url,
      :post_type,
      :start_date,
      :end_date,
      :hour_start,
      :hour_end
    )
  end

  def rich_menu_params
    params.permit(
      :current_tab,
      :search_text,
      #:search_account,
      :search_url,
      :start_date,
      :end_date,
      :sort
    )
  end

  def search_results_to_csv(relation, file_name)
    # ヘッダーのみCSVの作成
    bom = "\xEF\xBB\xBF"
    csv_data = CSV.generate(bom, row_sep: "\r\n", force_quotes: true) do |csv|
      header = [
        '媒体',
        'アカウントID',
        'アカウント名',
        'ブランド名',
        '業種',
        '企業名',
        '最新投稿日',
        '投稿数',
        '反応数',
        'フォロワー増加数',
        'フォロワー増加率',
        '反応数増加率'
      ]
      csv << header
      batch_size = 100_000
      0.step(by: batch_size) do |offset|
        # 100_000件分の配列を取得する
        csv_rows = Account.fetch_csv_row_post(relation, offset, batch_size)
        # 配列からCSVファイルへ書き込み
        csv_rows.each do |row|
          csv << row
        end
        # バッチサイズより小さければ終了
        break if csv_rows.length < batch_size
      end
    end
    respond_to do |format|
      format.csv do
        send_data csv_data, filename: file_name
      end
    end
  end
end
