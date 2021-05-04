FactoryBot.define do
  factory :account do
    brand_id      { 1 }
    media         { "Instagram" }
    name          { "アカウント1" }
    icon_s3 { "http://fake_address" }
    max_posted_at { "2021/03/01".to_date }
  end
end
