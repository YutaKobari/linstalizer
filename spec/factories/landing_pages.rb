FactoryBot.define do
  factory :landing_page do
    brand_id { 1 }
    max_published_at { Date.today }
    thumbnail_s3 { "http://thumbnail" }
    title { "background_lp" }
    sequence(:url_hash, "test_url_hash1")
    redirect_url { "http://landing/page/url" }
    description { "新生活が始まる季節にぴったりな、フルーティーなバナナの甘さと、アーモンドミルクのほのかな香ばしさを楽しめるフラペチーノ® が登場。新しいスタイルで楽しむフードの開発ストーリーや、新生活をいろどるカラフルなグッズの情報を先行してご紹介します。" }
  end

  trait :landing_page2 do
    title { "another_lp" }
    url_hash { "another_url_hash" }
    redirect_url { "http://another_landingpage" }
    description { "another_lp_desctiption" }
  end
end
