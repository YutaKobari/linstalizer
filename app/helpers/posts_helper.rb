module PostsHelper
  def display_post_type(post_type, href)
    # 実際のデータがどのような形式でくるかによって変更が必要
    display_hash = { 'normal_post' => '通常投稿', 'feed' => 'フィード', 'reel' => 'リール', 'story' => 'ストーリー', 'fleet' => 'フリート',
                     'tweet' => 'ツイート', 'retweet' => 'リツイート' }
    link_to display_hash[post_type], href, class: "#{post_type}_icon btn btn-sm btn-secondary"
  end

  def get_post_type_option_hash_by_media(media)
    case media
    when 'LINE'
      { 通常投稿: 'normal_post' }
    when 'Instagram'
      { フィード: 'feed', リール: 'reel', ストーリー: 'story' }
    when 'Twitter'
      { ツイート: 'tweet', リツイート: 'retweet' }
    when 'Facebook'
      {}
    else
      { 通常投稿: 'normal_post', フィード: 'feed', リール: 'reel', ストーリー: 'story', ツイート: 'tweet', リツイート: 'retweet' }
    end
  end

  def get_sort_option_hash_by_media(media)
    hash = { 投稿が新しい順: 'posted_at', いいね数: 'like' }
    hash[:リツイート数] = 'retweet' if media == 'Twitter'
    hash
  end
end
