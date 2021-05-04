class HashTagForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  validates_inclusion_of :sort, in: %w[post_increment total_reaction_increment], allow_blank: true

  attribute :search_hash_tag, :string
  attribute :aggregated_from, :date
  attribute :aggregated_to  , :date
  attribute :sort           , :string
  attribute :media          , :string

  def search
    return HashTag.none unless valid?
    self.aggregated_from ||= Date.today - 6.days
    self.aggregated_to ||= Date.today

    HashTag
      .search_by_hash_tag(search_hash_tag)
      .join_posts_and_select_increment_values(aggregated_from, aggregated_to)
      .where_media(media)
      .order_by(sort)
  end
end
