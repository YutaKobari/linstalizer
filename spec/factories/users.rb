FactoryBot.define do
  factory :user do
    name     { "テストユーザー" }
    email    { "tester@example.com" }
    password { '000000' }
  end
end
