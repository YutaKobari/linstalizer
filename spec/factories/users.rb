FactoryBot.define do
  factory :user do
    contractor_id { 1 }
    name     { "テストユーザー" }
    email    { "tester@example.com" }
    password { '000000' }
    is_admin { 1 }
    is_available { 1 }
  end
end
