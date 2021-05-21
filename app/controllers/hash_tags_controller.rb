class HashTagsController < ApplicationController

  def index
    @search_params = hash_tag_params
    hash_tag_form = HashTagForm.new(hash_tag_params)
    @hash_tags = hash_tag_form.search.page(params[:page]).without_count.per(50)
    @aggregated_from = params[:aggregated_from]&.to_date || Date.today - 6.days
    @aggregated_to = params[:aggregated_to]&.to_date || Date.today
  end

  def csv_download
    hash_tag_form = HashTagForm.new(hash_tag_params)
    relation = hash_tag_form.search
    search_results_to_csv(relation, 'hash_tags.csv')
  end

  private

  def hash_tag_params
    params.permit(
      :search_hash_tag,
      :aggregated_from,
      :aggregated_to,
      :sort,
      :media
    )
  end

  def search_results_to_csv(relation, file_name)
    # ヘッダーのみCSVの作成
    bom = "\xEF\xBB\xBF"
    csv_data = CSV.generate(bom, row_sep: "\r\n", force_quotes: true) do |csv|
      header = [
        'ハッシュタグ',
        '媒体',
        '投稿数',
        '反応数'
      ]
      csv << header
      batch_size = 100_000
      0.step(by: batch_size) do |offset|
        # 100_000件分の配列を取得する
        csv_rows = HashTag.fetch_csv_row_post(relation, offset, batch_size)
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
