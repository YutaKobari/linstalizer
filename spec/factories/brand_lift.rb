FactoryBot.define do
  factory :brand_lift do
    brand_id    { 1 }
    date        { Date.today }
    familiarity { 100 }
  end
end
