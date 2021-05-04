FactoryBot.define do
  factory :talk_post_content do
    account_id { 1 }
    brand_id   { 1 }
    post_type  { 'image' }
    text       { 'テキスト' }
    sequence(:url_hash, "url_hash1")
    sequence(:talk_group_hash, "talk_group_hash1")
    posted_at  { '2021/02/01 10:00 JTC'.to_time }
  end
end
