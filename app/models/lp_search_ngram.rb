class LpSearchNgram < ApplicationRecord
  self.table_name = 'lp_search_ngrams'

  def self.fetch_url_hash_from_search_ngram(text)
    self.where(sanitize_sql_array([%!MATCH(`search_ngram`) AGAINST(? in boolean mode)!, "+#{text}"]))
    .pluck(:url_hash)
  end

end
