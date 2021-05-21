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

  context '投稿詳細画面へ遷移' do
    background do
    end
    scenario 'Instagram投稿をクリックしてInstagram投稿詳細画面へ遷移できる' do
      post = FactoryBot.create(:post, :feed)
      visit posts_path
      first('tbody tr').click
      within_window(windows.last) do
        expect(current_path).to eq post_path(id: 1)
        expect(page).to have_content post.text
      end
    end
  end

  context '投稿文にscriptタグが含まれているとき' do
    scenario 'エスケープして出力できる' do
      FactoryBot.create(:post, :feed, text: "<script>console.log('xss');</script>")
      visit post_path(1)
      expect(page).to have_content('console.log')
    end
  end

  context 'パンくずリスト' do
    background do
      FactoryBot.create(:post)
    end

    scenario 'SNSをクリックするとSNSで絞り込んだアカウント一覧表示に遷移' do
      visit post_path(1)
      find('.breadcrumb-item', text: "Instagram").click
      expect(page).to have_current_path(accounts_path(media: "Instagram"))
    end

    scenario 'アカウント名をクリックするとアカウント詳細ページに遷移' do
      visit post_path(1)
      find('.breadcrumb-item', text: "アカウント1").click
      expect(page).to have_current_path(account_path(1))
    end

    scenario '投稿詳細が表示されている' do
      visit post_path(1)
      expect(find('.breadcrumb-item > .disable_a')).to have_content("投稿詳細")
    end
  end
end
