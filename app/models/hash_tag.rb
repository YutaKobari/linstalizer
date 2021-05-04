class HashTag < ApplicationRecord
  has_many :post_hash_tags
  has_many :posts, through: :post_hash_tags, primary_key: :hash_tag_id

  scope :search_by_hash_tag, -> (search_hash_tag) do
    return if search_hash_tag.blank?
    where("name LIKE ?", "%#{search_hash_tag}%")
  end

  scope :join_posts_and_select_increment_values, -> (aggregated_from, aggregated_to) do
    select('hash_tags.*, COUNT(posts.id) AS post_increment, SUM(posts.like_count) AS total_reaction_increment')
    .joins("INNER JOIN post_hash_tags pht ON hash_tags.id = pht.hash_tag_id INNER JOIN posts ON pht.post_id = posts.id AND posts.posted_at BETWEEN '#{aggregated_from}' AND '#{aggregated_to}'")
    .group('hash_tags.id')
  end

  scope :where_media, -> (media) do
    return if media.blank?
    where(media: media)
  end

  scope :order_by, -> (sort) do
    case sort
    when 'total_reaction_increment' then
      order("total_reaction_increment DESC")
    else
      order("post_increment DESC")
    end
  end

  def fetch_tagged_posts(aggregated_from, aggregated_to)
    posts
    .between_posted_at(aggregated_from, aggregated_to)
    .order(posted_at: 'DESC')
    .limit(30)
  end
end
