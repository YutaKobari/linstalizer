module PostsHelper
  def display_post_type(post_type, href)
    # 実際のデータがどのような形式でくるかによって変更が必要
    display_hash = { 'normal_post' => 'タイムライン投稿', 'feed' => 'フィード', 'reel' => 'リール', 'story' => 'ストーリー' }
    link_to display_hash[post_type], href, class: "#{post_type}_icon btn btn-sm btn-secondary"
  end

  def get_post_type_option_hash_by_media(media)
    case media
    when 'LINE'
      { タイムライン投稿: 'normal_post' }
    when 'Instagram'
      { フィード: 'feed', リール: 'reel', ストーリー: 'story' }
    else
      { タイムライン投稿: 'normal_post', フィード: 'feed', リール: 'reel', ストーリー: 'story' }
    end
  end

  def get_sort_option_hash_by_media(media)
    hash = { 投稿が新しい順: 'posted_at', いいね数: 'like' }
  end
end
