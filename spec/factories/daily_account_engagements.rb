FactoryBot.define do
  factory :daily_account_engagement do
    account_id     { 1 }
    date           { '2021/2/10'.to_date }
    follower       { 1000 }
    post_count     { 50 }
    total_reaction { 3000 }

    trait :nth_daily_account_engagement do
      sequence(:account_id, 2)
      date           { '2021/2/10'.to_date }
      follower       { 1000 }
      post_count     { 50 }
      total_reaction { 3000 }
    end
  end
end
