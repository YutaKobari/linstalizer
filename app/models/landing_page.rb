class LandingPage < ApplicationRecord
  has_many :posts, primary_key: :url_hash, foreign_key: :url_hash
  has_one  :lp_combined_urls, primary_key: :url_hash, foreign_key: :url_hash
  has_one  :lp_search_ngrams, primary_key: :url_hash, foreign_key: :url_hash
  belongs_to  :brand

  scope :where_market_id, -> (market_id) do
    return if market_id.blank?
    joins(:brand)
    .where('brands.market_id = ?', market_id)
  end

  scope :fulltext_search_by_text, -> (search_text) do
    return if search_text.blank?
    search_safe = search_text.gsub(/[\\%_]/){|m| "\\#{m}"}
    url_hashes = LpSearchNgram.fetch_url_hash_from_search_ngram(search_safe)
    where(url_hash: url_hashes)
  end

  scope :fulltext_search_by_url, -> (search_url) do
    return if search_url.blank?
    url_hashes = LpCombinedUrl.fetch_url_hash_from_combined_url(search_url)
    where(url_hash: url_hashes)
  end

  scope :between_max_published_at, -> (started_at, finished_at) do
    return if started_at.blank? && finished_at.blank?
    if started_at.present? && finished_at.present?
      where(max_published_at: started_at..finished_at)
    elsif started_at.present? && finished_at.blank?
      where(max_published_at: started_at..LandingPage.all.order(:max_published_at).first&.max_published_at)
    else
      where(max_published_at: "2021/02/01".to_date..finished_at)
    end
  end

  scope :select_post_counts, -> do
    select(<<-EOS
      landing_pages.*,
      count(*) post_counts
      EOS
    ).joins(:posts).group(:id)
  end

  scope :order_by, -> (sort) do
    case sort
    when 'max_published_at' then
      order("max_published_at DESC")
    when 'post_counts' then
      order("post_counts DESC")
    else
      order("post_counts DESC")
    end
  end

  scope :where_is_favorite, -> (is_favorite) do
    return if is_favorite.blank?
    favorite_brand_ids = User.current.accounts.distinct.pluck(:brand_id)
    where(brand_id: favorite_brand_ids)
  end
end
