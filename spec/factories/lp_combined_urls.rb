FactoryBot.define do
  factory :lp_combined_url do
    sequence(:url_hash, "test_url_hash1")
    combined_url { "http://example.com/" }
    brand_id { 1 }
    trait :lp_combined_url2 do
      combined_url { "http://amazon.com/" }
    end
  end
end
