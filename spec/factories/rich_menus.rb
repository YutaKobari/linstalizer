FactoryBot.define do
  factory :rich_menu do
    account_id { 1 }
    raw_post_id { 'raw_post_id' }
    date_from { '2021/02/01'.to_date }
    content_url { 'http://localhost:3000/rich_menus' }
    sequence(:group_hash, 'group_hash1')
  end
end