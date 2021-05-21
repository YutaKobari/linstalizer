FactoryBot.define do
  factory :notification do
    title { 'お知らせ' }
    posted_at { '2021/02/01'.to_date }
    is_active { true }
  end

  trait :inactive do
    is_active { false }
    title { 'inactive' }
  end
end
