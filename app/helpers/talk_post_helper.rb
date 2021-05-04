module TalkPostHelper
  def display_talk_post_type(post_type, href)
    # 実際のデータがどのような形式でくるかによって変更が必要
    display_hash = { 'text' => 'テキストメッセージ', 'image' => '画像メッセージ', 'video' => '動画メッセージ', 'image_map' => 'イメージマップ',
                     'carousel' => 'カルーセル' }
    link_to display_hash[post_type], href, class: 'badge badge-pill badge-lg badge-default'
    # TODO: トーク投稿タイプ別のアイコンの表示
  end

  def get_talk_post_type_option_hash
    {テキストメッセージ: 'text', 画像メッセージ: 'image', 動画メッセージ: 'video', スタンプ: 'stamp', イメージマップ: 'image_map', カルーセル: 'carousel'}
  end

  def display_thumbnail(talk_post_content)
    if talk_post_content.post_type == 'text'
      content_tag(:span, class: 'card card-body shadow-none bg-lighter', style: 'white-space: normal; max-height: 250px; width: 250px'){
        content_tag(:span, class: 'overflow-auto text-default'){ (text_url_to_link talk_post_content.text).html_safe }
      }
    else
      image_tag talk_post_content.content_url || 'https://picsum.photos/250/250', class: 'rounded d-inline-block',
            style: 'max-height: 250px; max-width: 300px;'
    end
  end
end
