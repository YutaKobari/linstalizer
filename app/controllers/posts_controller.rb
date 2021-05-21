class PostsController < ApplicationController
  before_action :find_post, only: [:show]
  def index
    @search_params = post_params
    post_form = PostForm.new(post_params)
    @posts = post_form.search.page(params[:page]).without_count.per(50)
  end

  def show
  end

  def csv_download
    post_form = PostForm.new(post_params)
    relation = post_form.search
    search_results_to_csv(relation, 'posts.csv')
  end

  private

  def post_params
    params.permit(
      :search_text,
      :search_account,
      :market_id,
      :search_hash_tag,
      :search_url,
      :media,
      :post_type,
      :start_date,
      :end_date,
      :hour_start,
      :hour_end,
      :sort,
      :is_favorite,
    )
  end

  def find_post
    @post = Post.find params[:id]
  end

  def search_results_to_csv(relation, file_name)
    # ヘッダーのみCSVの作成
    bom = "\xEF\xBB\xBF"
    csv_data = CSV.generate(bom, row_sep: "\r\n", force_quotes: true) do |csv|
      header = [
        'アカウント名',
        'ブランド名',
        '業種',
        '媒体',
        '投稿タイプ',
        '画像/動画',
        'コンテンツURL',
        '投稿内容',
        'いいね数',
        '投稿日時',
        '遷移先URL'
      ]
      csv << header
      batch_size = 100_000
      0.step(by: batch_size) do |offset|
        # 100_000件分の配列を取得する
        csv_rows = Post.fetch_csv_row_post(relation, offset, batch_size)
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
