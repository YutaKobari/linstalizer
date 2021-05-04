module HashTagHelper
  def display_thumbnail_link(post)
    external_link_to image_tag(post&.content_url, class: 'rounded d-inline-block', style: 'max-height: 250px; max-width: 300px;'), post_path(post.id)
  end
end
