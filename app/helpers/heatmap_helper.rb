module HeatmapHelper
  def post_type_icon(post_type, media)
    "<span class='#{post_type}_icon #{media}_color heatmap_icon' style='font-size:12px;'></span>".html_safe
  end

  def bg_color_by_value(sum_post_count_per_hour, max_post_count_per_hour)
    # 基準値を １時間単位で最大の投稿数 / 10で設定
    standard_value = max_post_count_per_hour / 10.0
    if sum_post_count_per_hour > standard_value * 10
      'post_count_10'
    elsif sum_post_count_per_hour > standard_value * 9
      'post_count_9'
    elsif sum_post_count_per_hour > standard_value * 8
      'post_count_8'
    elsif sum_post_count_per_hour > standard_value * 7
      'post_count_7'
    elsif sum_post_count_per_hour > standard_value * 6
      'post_count_6'
    elsif sum_post_count_per_hour > standard_value * 5
      'post_count_5'
    elsif sum_post_count_per_hour > standard_value * 4
      'post_count_4'
    elsif sum_post_count_per_hour > standard_value * 3
      'post_count_3'
    elsif sum_post_count_per_hour > standard_value * 2
      'post_count_2'
    elsif sum_post_count_per_hour > standard_value
      'post_count_1'
    else
      ''
    end
  end
end
