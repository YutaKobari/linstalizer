FactoryBot.define do
  factory :lp_search_ngram, class: 'LpSearchNgram' do
    search_ngram { "test1キーワードlp1詳細" }
    brand_id { 1 }
  end

  factory :lp_search_ngram2, class: 'LpSearchNgram' do
    search_ngram { "当たるんです高確率ロトくじの当たるんです！" }
    brand_id { 1 }
  end
end
