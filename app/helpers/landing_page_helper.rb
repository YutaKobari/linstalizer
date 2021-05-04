module LandingPageHelper
  def get_sort_list_for_landing_pages
    [['リンク元投稿数順', 'post_counts'], ['最新出稿日順', 'max_published_at']]
  end
end
