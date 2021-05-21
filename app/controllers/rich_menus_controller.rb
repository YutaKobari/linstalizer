class RichMenusController < ApplicationController
  before_action :find_rich_menu, only: [:show]
  def index
    @search_params = rich_menu_params
    rich_menu_form = RichMenuForm.new(rich_menu_params)
    @rich_menus = rich_menu_form.search.page(params[:page]).without_count.per(50)
  end

  def show
    @rich_menu_contents = RichMenuContent.where(group_hash: @rich_menu.group_hash)
  end
  
  def csv_download
    rich_menu_form = RichMenuForm.new(rich_menu_params)
    relation = rich_menu_form.search
    search_results_to_csv(relation, 'rich_menus.csv')
  end

  private

  def rich_menu_params
    params.permit(
      :search_text,
      :search_account,
      :market_id,
      :search_url,
      :start_date,
      :end_date,
      :sort,
      :is_favorite,
    )
  end

  def find_rich_menu
    @rich_menu = RichMenu.find(params[:id])
  end

  def search_results_to_csv(relation, file_name)
    # ヘッダーのみCSVの作成
    bom = "\xEF\xBB\xBF"
    csv_data = CSV.generate(bom, row_sep: "\r\n", force_quotes: true) do |csv|
      header = [
        'アカウント名',
        'ブランド名',
        '業種',
        'サムネイル',
        '表示開始日',
        '表示終了日'
      ]
      csv << header
      batch_size = 100_000
      0.step(by: batch_size) do |offset|
        # 100_000件分の配列を取得する
        csv_rows = RichMenu.fetch_csv_row_post(relation, offset, batch_size)
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
