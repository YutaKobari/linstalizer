class LandingPagesController < ApplicationController
  def index
    @search_params = lp_params
    lp_form = LpForm.new(lp_params)
    @landing_pages = lp_form.search.page(params[:page]).without_count.per(50)
  end

  def show
    @lp = LandingPage.find_by(id: params[:id])
    post_form = PostForm.new(post_params)
    @posts = post_form.search_in_lp_show(@lp.id).page(params[:page]).without_count.per(30)
  end

  def csv_download
    lp_form = LpForm.new(lp_params)
    relation = lp_form.search
    search_results_to_csv(relation, 'landing_pages.csv')
  end

  private

  def lp_params
    params.permit(
      :search_text    ,
      :market_id      ,
      :search_url     ,
      :media          ,
      :start_date     ,
      :end_date       ,
      :sort           ,
      :is_favorite    ,
    )
  end

  def post_params
    params.permit(
      :search_text,
      :search_hash_tag,
      :media,
      :post_type,
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
        'ブランド名',
        '業種',
        'サムネイル',
        'タイトル',
        'ディスクリプション',
        'リンク元投稿数'
      ]
      csv << header
      batch_size = 100_000
      0.step(by: batch_size) do |offset|
        # 100_000件分の配列を取得する
        csv_rows = LandingPage.fetch_csv_row_post(relation, offset, batch_size)
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
