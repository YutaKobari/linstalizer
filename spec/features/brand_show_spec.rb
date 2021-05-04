require 'rails_helper'

feature "ブランド詳細画面" do
   given(:email)    { 'tester@example.com' }
   given(:password) { '000000' }

  background do
    FactoryBot.create(:user)
    FactoryBot.create(:company)
    FactoryBot.create(:market)
    FactoryBot.create(:brand)
    FactoryBot.create(:account)
    FactoryBot.create(:daily_account_engagement)
    FactoryBot.create(:landing_page)
    FactoryBot.create(:lp_combined_url)
    FactoryBot.create(:post)

    FactoryBot.create(:brand_lift_value, date: Date.today, value: 100)
    FactoryBot.create(:brand_lift_value, date: Date.today+1.days, value: 100)
    FactoryBot.create(:brand_lift_value, :line_friends, date: Date.today, value: 100)
    FactoryBot.create(:brand_lift_value, :line_friends, date: Date.today+1.days, value: 100)
    FactoryBot.create(:brand_lift_value, :youtube_hits, date: Date.today, value: 100)
    FactoryBot.create(:brand_lift_value, :youtube_hits, date: Date.today+1.days, value: 100)
    FactoryBot.create(:brand_lift_value, :insta_followers, date: Date.today, value: 100)
    FactoryBot.create(:brand_lift_value, :insta_followers, date: Date.today+1.days, value: 100)

    # Login
    visit root_path
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    click_on 'ログイン'
    visit brand_path(1)
  end

  scenario 'アカウント一覧からブランド詳細画面へ遷移できる' do
    visit accounts_path
    find('td a', text: 'test_brand_name').click
    within_window(windows.last) do
      expect(page).to have_current_path brand_path(1)
    end
  end

  scenario "titleタグがパンくずのテキストになっている" do
    expect(page).to have_current_path brand_path(1)
  end

  context 'パンくずリスト' do
    scenario '全メディアをクリックするとアカウント一覧表示に遷移' do
      visit brand_path(1)
      find('.breadcrumb-item', text: "全メディア").click
      expect(page).to have_current_path(accounts_path)
    end

    scenario 'ブランド名が表示されている' do
      visit brand_path(1)
      expect(find('.breadcrumb-item > .disable_a')).to have_content("test_brand_name")
    end
  end

  context "タブ切り替え機能" do
    scenario "デフォルトで投稿一覧のタブが表示されている" do
      expect(page).to have_css('#tabs-icons-text-1-tab.active')
    end
    scenario "投稿推移（集計）のタブに切り替える" do
      click_on "投稿推移（集計）"
      expect(page).to have_css('#tabs-icons-text-2-tab.active')
    end
    scenario "絞り込みボタンを押した後も遷移前のタブの状態が維持される" do
      find('#headingTwo').click
      find('#tabs-icons-text-1 input[value="絞り込み"]').click
      expect(page).to have_css('#tabs-icons-text-1-tab.active')

      click_on "投稿推移（集計）"
      find('#tabs-icons-text-2 input[value="絞り込み"]').click
      expect(page).to have_css('#tabs-icons-text-2-tab.active')
    end
  end

  describe "ブランドリフトグラフのテスト" do
    example "ブランドリフトグラフが表示されている" do
      expect(page).to have_selector('canvas#google_trend_chart')
      expect(page).to have_selector('canvas#line_friends_chart')
      expect(page).to have_selector('canvas#youtube_hits_chart')
      expect(page).to have_selector('canvas#insta_followers_chart')
    end
    example "アイコンが表示されている" do
      FactoryBot.create(:post, posted_on: Date.today, media: "LINE")
      FactoryBot.create(:post, posted_on: Date.today, media: "Instagram")
      FactoryBot.create(:post, posted_on: Date.today, media: "Twitter")
      FactoryBot.create(:post, posted_on: Date.today, media: "Facebook")
      visit current_path
      expect(page).to have_selector('.LINE_circle_icon')
      expect(page).to have_selector('.Instagram_circle_icon')
      expect(page).to have_selector('.Twitter_circle_icon')
      expect(page).to have_selector('.Facebook_circle_icon')
    end
    example "アイコンに投稿数が表示される" do
      FactoryBot.create(:post, posted_on: Date.today.beginning_of_month, media: "LINE")
      FactoryBot.create(:post, posted_on: Date.today.beginning_of_month, media: "LINE")
      FactoryBot.create(:post, posted_on: Date.today.beginning_of_month, media: "Twitter")
      FactoryBot.create(:post, posted_on: Date.today.beginning_of_month + 1.days, media: "LINE")
      visit current_path
      expect(find('.LINE_circle_icon.LINE_brandlift_icon0', match: :first).text).to eq "2"
      expect(find('.Twitter_circle_icon.Twitter_brandlift_icon0', match: :first).text).to eq "1"
      expect(find('.LINE_circle_icon.LINE_brandlift_icon1', match: :first).text).to eq "1"
    end

    example "アイコンは上に他のアイコンがなければ詰めて表示される" do
      FactoryBot.create(:post, posted_on: Date.today.beginning_of_month, media: "Facebook")
      visit current_path
      expect(find('.Facebook_circle_icon.Facebook_brandlift_icon0', match: :first).text).to eq "1"
      expect(page).to have_css('.ch1-column0-row0 span.Facebook_circle_icon')
    end

    example "トーク投稿のみの場合でもアイコンに投稿数が正常に表示される" do
      FactoryBot.create(:talk_post, posted_on: Date.today.beginning_of_month)
      visit current_path
      expect(find('.LINE_circle_icon.LINE_brandlift_icon0', match: :first).text).to eq "1"
    end
    example "投稿がない日はアイコンが表示されない" do
      visit current_path
      expect(page).not_to have_css('.LINE_circle_icon.LINE_brandlift_icon0')
    end
    example "アイコンをクリックするとそのメディアのアカウント詳細画面に遷移し、パラメータにその日付がstart_date, end_dateとして設定されている" do
      FactoryBot.create(:post, posted_on: Date.today.beginning_of_month, media: "Instagram")
      visit current_path
      find('.Instagram_circle_icon.Instagram_brandlift_icon0', match: :first).click
      expect(page).to have_current_path(account_path(1) + "?start_date=#{Date.today.beginning_of_month.strftime}&end_date=#{Date.today.beginning_of_month.strftime}")
    end
    example "期間を絞り込むとその期間のブランドリフトのみが表示される" do
      FactoryBot.create(:brand_lift_value, date: Date.new(2021,1,1), value: 100)
      FactoryBot.create(:brand_lift_value, date: Date.new(2021,1,2), value: 200)
      FactoryBot.create(:post, posted_on: Date.new(2021,1,1), media: "Facebook")
      select '2021年1月', from: 'brandlift_month'
      click_on('絞り込み')
      expect(find('.Facebook_circle_icon.Facebook_brandlift_icon0', match: :first).text).to eq "1"
    end
    example "デフォルトの状態だと期間は今月になっている" do
      FactoryBot.create(:brand_lift_value, date: Date.today.beginning_of_month, value: 100)
      FactoryBot.create(:post, posted_on:  Date.today.beginning_of_month, media: "Twitter")
      visit current_path
      expect(find('.Twitter_circle_icon.Twitter_brandlift_icon0', match: :first).text).to eq "1"
      expect(page).to have_select('brandlift_month', selected: "#{Date.today.year}年#{Date.today.month}月")
    end
  end
end
