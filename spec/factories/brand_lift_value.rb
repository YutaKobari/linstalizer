FactoryBot.define do
  factory :brand_lift_value do
    brand_id    { 1 }
    type_id     { 2 }
    date        { Date.today }
    value { 100 }
  end

  trait :line_friends do
    type_id { 4 }
  end

  trait :youtube_hits do
    type_id { 5 }
  end

  trait :insta_followers do
    type_id { 6 }
  end
end
