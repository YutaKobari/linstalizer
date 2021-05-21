class TalkPostsController < ApplicationController
  before_action :find_talk_post, only: [:show]
  def index
    @search_params = post_params
    post_form = TalkPostForm.new(post_params)
    @talk_post_contents = post_form.search.page(params[:page]).without_count.per(50)
  end

  def show
  end

  def csv_download
    talk_post_form = TalkPostForm.new(post_params)
    relation = talk_post_form.search_for_csvdl # group_byを行わない
    search_results_to_csv(relation, 'talk_posts.csv')
  end

  def post_params
    params.permit(
      :search_text,
      :search_account,
      :search_url,
      :market_id,
      :post_type,
      :start_date,
      :end_date,
      :hour_start,
      :hour_end,
      :is_favorite,
    )
  end

  private

  def find_talk_post
    @talk_post = TalkPost.find(params[:id])
  end

  def search_results_to_csv(relation, file_name)
    # ヘッダーのみCSVの作成
    bom = "\xEF\xBB\xBF"
    csv_data = CSV.generate(bom, row_sep: "\r\n", force_quotes: true) do |csv|
      header = [
        'アカウント名',
        'ブランド名',
        '業種',
        '投稿タイプ',
        '投稿内容',
        '投稿日時',
        '遷移先URL'
      ]
      csv << header
      batch_size = 100_000
      0.step(by: batch_size) do |offset|
        # 100_000件分の配列を取得する
        csv_rows = TalkPostContent.fetch_csv_row_post(relation, offset, batch_size)
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
