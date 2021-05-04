FactoryBot.define do
  factory :rich_menu_content do
    account_id { 1 }
    raw_post_id { 'raw_post_id' }
    content_url { 'http://localhost:3000/rich_menus' }
    url_hash { 'test_url_hash1' }
    redirect_url { 'http://localhost:3000/rich_menus' }
    sequence(:group_hash, 'group_hash1')
  end
end
