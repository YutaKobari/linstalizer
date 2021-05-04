FactoryBot.define do
  factory :talk_post do
    account_id          { 1 }
    brand_id            { 1 }
    posted_at           { '2021/02/01 10:00 JTC'.to_time }
    posted_on           { '2021/02/01' }
    sequence(:talk_group_hash, "talk_group_hash1")
  end
end
