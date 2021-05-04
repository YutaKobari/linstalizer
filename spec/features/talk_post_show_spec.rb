require 'rails_helper'

feature '投稿詳細画面' do
  given(:email) { 'tester@example.com' }
  given(:pwd) { '000000' }
  background do
    @user = FactoryBot.create(:user)
    # Login
    visit root_path
    fill_in 'user_email', with: email
    fill_in 'user_password', with: pwd
    click_on 'ログイン'
    visit posts_path
    FactoryBot.create(:company)
    FactoryBot.create(:market)
    FactoryBot.create(:brand)
    FactoryBot.create(:account)
    FactoryBot.create(:daily_account_engagement)
    FactoryBot.create(:landing_page)
    FactoryBot.create(:lp_combined_url)
  end

  context 'パンくずリスト' do
    background do
      FactoryBot.create(:talk_post)
    end

    scenario 'メディアをクリックするとメディアで絞り込んだアカウント一覧表示に遷移' do
      visit talk_post_path(1)
      sleep 2
      find('.breadcrumb-item', text: "LINE").click
      expect(page).to have_current_path(accounts_path(media: "LINE"))
    end

    scenario 'アカウント名をクリックするとアカウント詳細ページに遷移' do
      visit talk_post_path(1)
      find('.breadcrumb-item', text: "アカウント1").click
      expect(page).to have_current_path(account_path(1))
    end

    scenario 'トーク投稿詳細が表示されている' do
      visit talk_post_path(1)
      expect(find('.breadcrumb-item > .disable_a')).to have_content("トーク投稿詳細")
    end
  end
end
