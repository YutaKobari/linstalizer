require 'rails_helper'
require 'rails_helper'

feature "ブランド詳細画面 ヒートマップ" do
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
    FactoryBot.create(:post, posted_at: Date.today)
    # Login
    visit root_path
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    click_on 'ログイン'
  end

  context "ヒートマップのアイコン表示" do
    background do
      FactoryBot.create(:post, hour: 1, day: 0, post_type: "normal_post", media: "LINE", posted_at: Date.today)
      FactoryBot.create(:post, hour: 2, day: 0, post_type: "tweet", media: "Twitter", posted_at: Date.today)
      FactoryBot.create(:post, hour: 3, day: 0, post_type: "reel", media: "Instagram", posted_at: Date.today)
      FactoryBot.create(:post, hour: 4, day: 0, post_type: "retweet", media: "Twitter", posted_at: Date.today)
      FactoryBot.create(:talk_post, hour: 5, day: 0, posted_at: Date.today)
      FactoryBot.create(:talk_post_content)
      FactoryBot.create(:post, hour: 6, day: 0, post_type: "story", media: "Instagram", posted_at: Date.today)
      FactoryBot.create(:post, hour: 7, day: 0, post_type: "fleet", media: "Twitter", posted_at: Date.today)
      visit brand_path(1)
      switch_to_window(windows.last)
      click_on "投稿推移（集計）"
    end

    scenario "ヒートマップが表示されている" do
      expect(page).to have_selector('table.heatmap-tbl')
    end

    scenario "フィードのアイコンが表示されている" do
      sleep 1
      expect(find('.hour-0.day-0 span')[:class]).to include('feed_icon')
      expect(find('.hour-0.day-0')).to have_text('1')
    end

    scenario "通常投稿のアイコンが表示されている" do
      sleep 1
      expect(find('.hour-1.day-0 span')[:class]).to include('normal_post_icon')
      expect(find('.hour-1.day-0')).to have_text('1')
    end

    scenario "ツイートのアイコンが表示されている" do
      sleep 1
      expect(find('.hour-2.day-0 span')[:class]).to include('tweet_icon')
      expect(find('.hour-2.day-0')).to have_text('1')
    end

    scenario "リールのアイコンが表示されている" do
      sleep 1
      expect(find('.hour-3.day-0 span')[:class]).to include('reel_icon')
      expect(find('.hour-3.day-0')).to have_text('1')
    end

    scenario "リツイートのアイコンが表示されている" do
      sleep 1
      expect(find('.hour-4.day-0 span')[:class]).to include('retweet_icon')
      expect(find('.hour-4.day-0')).to have_text('1')
    end

    scenario "トーク投稿のアイコンが表示されている" do
      sleep 1
      expect(find('.hour-5.day-0 span')[:class]).to include('talk_post_icon')
      expect(find('.hour-5.day-0')).to have_text('1')
    end

    scenario "ストーリーのアイコンが表示されている" do
      sleep 1
      expect(find('.hour-6.day-0 span')[:class]).to include('story_icon')
      expect(find('.hour-6.day-0')).to have_text('1')
    end

    scenario "フリートのアイコンが表示されている" do
      sleep 1
      expect(find('.hour-7.day-0 span')[:class]).to include('fleet_icon')
      expect(find('.hour-7.day-0')).to have_text('1')
    end

    scenario "hour,day,post_typeが同じ投稿の数だけアイコン横の数字が増える" do
      FactoryBot.create(:post, hour: 0, day: 1, post_type: "feed", posted_at: Date.today)
      FactoryBot.create(:post, hour: 0, day: 1, post_type: "feed", posted_at: Date.today)
      visit current_path
      click_on "投稿推移（集計）"
      sleep 1
      expect(find('.hour-0.day-1 span')[:class]).to include("feed")
      expect(find('.hour-0.day-1')).to have_text('2')
    end

    scenario "一つのセルに複数のアイコンが表示される" do
      FactoryBot.create(:post, hour: 0, day: 2, post_type: "feed", posted_at: Date.today )
      FactoryBot.create(:post, hour: 0, day: 2, post_type: "normal_post", posted_at: Date.today )
      visit current_path
      click_on "投稿推移（集計）"
      sleep 1
      expect(all('.hour-0.day-2 span')[0][:class]).to include("feed")
      expect(all('.hour-0.day-2 span')[1][:class]).to include("normal_post")
      expect(find('.hour-0.day-2')).to have_text('1 1')
    end

    # トーク投稿のみtalk_postsテーブルを参照しているため上のテストと別でテストしている
    scenario "トーク投稿の場合も一つのセルに複数のアイコンが表示される" do
      FactoryBot.create(:post, hour: 0, day: 3, post_type: "feed", posted_at: Date.today )
      FactoryBot.create(:talk_post, hour: 0, day: 3, posted_at: Date.today)
      visit current_path
      click_on "投稿推移（集計）"
      sleep 1
      expect(all('.hour-0.day-3 span')[0][:class]).to include("feed")
      expect(all('.hour-0.day-3 span')[1][:class]).to include("talk_post")
      expect(find('.hour-0.day-3')).to have_text('1 1')
    end

    scenario "アイコンをクリックするとモーダルが表示される" do
      expect(find('.modal', visible: false)).not_to be_visible
      find('.hour-0.day-0 a').click
      sleep 1
      expect(find('.modal', visible: false)).to be_visible
      click_on "閉じる"

      sleep 1
      expect(find('.modal', visible: false)).not_to be_visible
      find('.hour-5.day-0 a').click
      sleep 1
      expect(find('.modal', visible: false)).to be_visible
    end

    scenario "モーダルのメディア、投稿タイプがクリックしたアイコンと一致している" do
      find('.hour-0.day-0 a').click
      sleep 1
      expect(find('.modal-content td:first-child p:first-child').text).to eq "Instagram"
      expect(find('.modal-content td:first-child p:nth-child(2)').text).to eq "フィード"
      click_on "閉じる"
      sleep 1

      find('.hour-4.day-0 a').click
      sleep 1
      expect(find('.modal-content td:first-child p:first-child').text).to eq "Twitter"
      expect(find('.modal-content td:first-child p:nth-child(2)').text).to eq "リツイート"
    end

    scenario "モーダルの表示数がアイコンの表示数と一致している" do
      2.times { FactoryBot.create(:post, hour: 1, day: 0, post_type: "normal_post", media: "LINE", posted_at: Date.today) }
      visit current_path
      click_on "投稿推移（集計）"
      sleep 1
      expect(find('.hour-1.day-0')).to have_text('3')
      find('.hour-1.day-0 a').click
      sleep 1
      expect(all('.modal-content table tbody tr').size).to eq 3
    end
  end

  context "日付フォームの動作" do
    background do
      visit brand_path(1)
      click_on "投稿推移（集計）"
    end

    scenario "デフォルトの期間が今月に設定されている" do
      expect(find('#aggregated_from').value).to eq Date.today.beginning_of_month.strftime("%Y/%m/%d")
      expect(find('#aggregated_to').value).to eq Date.today.strftime("%Y/%m/%d")
    end

    scenario "期間を指定して絞り込むとパラメータにその期間が追加される" do
      find('#aggregated_from').set("2021/01/01")
      find('#aggregated_to').set("2021/01/02")
      within('.tab-pane') { click_on '絞り込み' }
      expect(current_url).to include("aggregated_from=2021%2F01%2F01")
      expect(current_url).to include("aggregated_to=2021%2F01%2F02")
    end

    scenario "集計期間のボタンで正しく日程がセットされるか" do
      today = Date.today
      find('#all_periods_aggregation', text: "全期間").click
      expect(find('#aggregated_from').value).to eq "2021/02/01" # 仮の最古の日付、契約者の契約期間にしたい
      expect(find('#aggregated_to').value).to eq "#{today.to_s.gsub("-", "/")}"

      find('#this_month_aggregation', text: "今月").click
      expect(find('#aggregated_from').value).to eq "#{today.beginning_of_month.to_s.gsub("-", "/")}"
      expect(find('#aggregated_to').value).to eq "#{today.to_s.gsub("-", "/")}"
      find('#thirty_days_aggregation', text: "30日間").click
      expect(find('#aggregated_from').value).to eq "#{(today-29.days).to_s.gsub("-", "/")}"
      expect(find('#aggregated_to').value).to eq "#{today.to_s.gsub("-", "/")}"
    end

    scenario "日付で絞り込むとその期間に投稿された投稿しか表示されない" do
      FactoryBot.create(:post, hour: 1, day: 0, posted_at: "2021/07/01")
      FactoryBot.create(:post, hour: 2, day: 0, posted_at: "2100/01/01")
      within('.tab-pane') { click_on '絞り込み' }
      expect(page).not_to have_css('.hour-1.day-0 span')
      expect(page).not_to have_css('.hour-2.day-0 span')
      find('#aggregated_from').set("2021/07/01")
      find('#aggregated_to').set("2021/07/02")
      within('.tab-pane') { click_on '絞り込み' }
      expect(find('.hour-1.day-0 span')[:class]).to include('feed_icon')
      expect(find('.hour-2.day-0')).not_to have_css('span')
    end
  end

  context "投稿タイプボタンの動作" do
    background do
      visit brand_path(1)
      click_on "投稿推移（集計）"
    end

    scenario "ボタンを押して絞り込むとパラメータにその投稿タイプが追加される" do
      find('.LINE-normal_post').click
      find('.LINE-talk_post').click
      within('.tab-pane') { click_on '絞り込み' }
      expect(current_url).to include("LINE-normal_post")
      expect(current_url).to include("LINE-talk_post")
      expect(current_url).to_not include("LINE-story")
    end

    scenario "絞り込みボタンを押した後もボタンの状態が維持されている" do
      expect(all('.LINE-normal_post .sns-checkbox', visible: false)[0].checked?).to eq false
      expect(all('.LINE-talk_post .sns-checkbox', visible: false)[0].checked?).to   eq false
      expect(all('.LINE-story .sns-checkbox', visible: false)[0].checked?).to       eq false
      find('.LINE-normal_post').click
      find('.LINE-talk_post').click
      within('.tab-pane') { click_on '絞り込み' }
      expect(all('.LINE-normal_post .sns-checkbox', visible: false)[0].checked?).to eq true
      expect(all('.LINE-talk_post .sns-checkbox', visible: false)[0].checked?).to   eq true
      expect(all('.LINE-story .sns-checkbox', visible: false)[0].checked?).to       eq false
    end

    scenario "全選択ボタンを押すと、そのメディアの全ての投稿タイプボタンが押される" do
      expect(find('.LINE-checkall').checked?).to eq false
      expect(all('.LINE-normal_post .sns-checkbox', visible: false)[0].checked?).to eq false
      expect(all('.LINE-talk_post .sns-checkbox', visible: false)[0].checked?).to   eq false
      expect(all('.LINE-story .sns-checkbox', visible: false)[0].checked?).to       eq false
      find('.LINE-checkall').set(true) # 全選択ボタンを押す
      expect(find('.LINE-checkall').checked?).to eq true
      expect(all('.LINE-normal_post .sns-checkbox', visible: false)[0].checked?).to eq true
      expect(all('.LINE-talk_post .sns-checkbox', visible: false)[0].checked?).to   eq true
      expect(all('.LINE-story .sns-checkbox', visible: false)[0].checked?).to       eq true
    end

    scenario "全選択ボタンのチェックを外すと、そのメディアの全ての投稿タイプボタンが解除される" do
      find('.LINE-checkall').set(true) # 全選択ボタンを押す
      expect(find('.LINE-checkall').checked?).to eq true
      expect(all('.LINE-normal_post .sns-checkbox', visible: false)[0].checked?).to eq true
      expect(all('.LINE-talk_post .sns-checkbox', visible: false)[0].checked?).to   eq true
      expect(all('.LINE-story .sns-checkbox', visible: false)[0].checked?).to       eq true
      find('.LINE-checkall').set(false) # 全選択ボタンを解除する
      expect(find('.LINE-checkall').checked?).to eq false
      expect(all('.LINE-normal_post .sns-checkbox', visible: false)[0].checked?).to eq false
      expect(all('.LINE-talk_post .sns-checkbox', visible: false)[0].checked?).to   eq false
      expect(all('.LINE-story .sns-checkbox', visible: false)[0].checked?).to       eq false
    end

    scenario "投稿タイプで絞り込むとその投稿タイプの投稿しか表示されない" do
      FactoryBot.create(:post, hour: 1, day: 0, posted_at: Date.today)
      FactoryBot.create(:post, :story, hour: 2, day: 0, posted_at: Date.today)
      within('.tab-pane') { click_on '絞り込み' }
      expect(find('.hour-1.day-0 span')[:class]).to include('feed_icon')
      expect(find('.hour-2.day-0 span')[:class]).to include('story_icon')
      find('.Instagram-feed').click
      within('.tab-pane') { click_on '絞り込み' }
      expect(find('.hour-1.day-0 span')[:class]).to include('feed_icon')
      expect(find('.hour-2.day-0')).not_to have_css('span')
    end
  end
end
