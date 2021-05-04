class Heatmap
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_reader :brand, :post_data_hashes, :max_post_count_per_hour

  attribute :media_post_types, :media_post_types # "LINE(media)-normal_post(post_type)のような形式を取る
  attribute :aggregated_from,  :date, default: Date.today.beginning_of_month
  attribute :aggregated_to,    :date, default: Date.today
  attribute :current_tab,      :string

  # TODO: aggregated_fromがaggregated_toを上回ってる場合に弾くバリデーションを書く

  def initialize(brand, params = {})
    @brand = brand
    super params
    @post_data_hashes = generate_post_data_hashes
    @max_post_count_per_hour = calc_max_post_count_per_hour
  end

  def post_data_per_hour(day:, hour:)
    post_data_per_hour = post_data_hashes.select {|hash| hash[:day] == day && hash[:hour] == hour }
    return if post_data_per_hour.empty?
    post_data_per_hour.push(post_data_per_hour.inject(0){|sum,i| sum+i[:post_count]}) # ヒートマップの色分け用に１時間単位の投稿数の合計値を取得
  end

  private

  def generate_post_data_hashes
    load_post_data.map do |r|
      {
        day:        r.day,
        hour:       r.hour,
        post_type:  r.post_type,
        media:      r.media,
        post_count: r.post_count,
      }
    end
  end
  # 時間帯ごとの投稿数の最大値を取得する, ヒートマップの色分けで最大の値として使用する
  def calc_max_post_count_per_hour
    return 0 if post_data_hashes.empty?
    post_data_hashes.group_by { |i| "#{i[:day]}" + "-" + "#{i[:hour]}" } # Hashをday,hourでグループ化（day-hourがkeyでpost_data_hashの配列がvalueのhashが生成）。
    # ex）{ 1-20 => [{day:1, hour:20, post_type:'feed', media:'Instagram', post_count:2}, {...}], 1-21 => [{...},{...}] }
    .map{|k,v| v.inject(0){|sum,i| sum + i[:post_count]}}.max # グループ化した結果のpost_countを畳み込んで合計値を計算、その最大値を得る
  end

  def load_post_data
    post_data = brand.posts.fetch_heatmap_data(aggregated_from: aggregated_from, aggregated_to: aggregated_to, media_post_types: media_post_types)
    if media_post_types.blank? || media_post_types&.any?{|h| h[:post_type] == 'talk_post'}
      post_data += brand.talk_posts.fetch_heatmap_data(aggregated_from: aggregated_from, aggregated_to: aggregated_to)
    else
      post_data
    end
  end
end
