class LpCombinedUrl < ApplicationRecord
  self.table_name = 'lp_combined_urls'

  def self.fetch_url_hash_from_combined_url(url)
    self.where(sanitize_sql_array([%!MATCH(`combined_url`) AGAINST(? in boolean mode)!, "+#{url}"]))
    .pluck(:url_hash)
  end
end
