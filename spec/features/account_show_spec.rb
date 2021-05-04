require 'rails_helper'

feature 'アカウント詳細画面' do
  given(:email)    { 'tester@example.com' }
  given(:password) { '000000' }

  background do
    FactoryBot.create(:user)
    FactoryBot.create(:company)
    FactoryBot.create(:market)
    FactoryBot.create(:brand)
    FactoryBot.create(:account)
    FactoryBot.create(:landing_page)
    FactoryBot.create(:lp_combined_url)
    FactoryBot.create(:daily_account_engagement)
    # Login
    visit root_path
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    click_on 'ログイン'
  end

  context '遷移' do
    scenario '投稿のアカウント名をクリックしてアカウント詳細画面へ正しく遷移できる' do
      FactoryBot.create(:post)
      visit posts_path
      click_link 'アカウント1'
      expect(page).to have_current_path account_path(1)
    end

    scenario 'アカウント一覧画面からアカウント詳細画面へ正しく遷移できる' do
      visit accounts_path
      find('tbody tr').click
      within_window(windows.last) do
        expect(page).to have_current_path account_path(1)
      end
    end
  end

  context 'パンくずリスト' do
    scenario 'メディアをクリックするとメディアで絞り込んだアカウント一覧表示に遷移' do
      visit account_path(1)
      find('.breadcrumb-item', text: "Instagram").click
      expect(page).to have_current_path(accounts_path(media: "Instagram"))
    end

    scenario 'アカウント名が表示されている' do
      visit account_path(1)
      expect(find('.breadcrumb-item > .disable_a')).to have_content("アカウント1")
    end
  end

  context 'アカウントの媒体種類表示' do
    background do
      # 同一会社、同一ブランドのLINEアカウントを作成
      FactoryBot.create(:account, media: 'LINE')
      FactoryBot.create(:daily_account_engagement, account_id: 2)
    end
    scenario 'デフォルトで正しい媒体が選択されている' do
      visit account_path(1)
      expect(page).to have_selector 'ul.nav .Instagram_btn'
      expect(page).not_to have_selector 'ul.nav .LINE_btn'
      visit account_path(2)
      expect(page).not_to have_selector 'ul.nav .Instagram_btn'
      expect(page).to have_selector 'ul.nav .LINE_btn'
    end
    scenario 'LINEをクリックしてLINEアカウント情報へ遷移できる' do
      visit account_path(1)
      find('ul.nav a.LINE_color').click
      expect(page).to have_current_path account_path(2)
      expect(page).not_to have_selector 'ul.nav .Instagram_btn'
      expect(page).to have_selector 'ul.nav .LINE_btn'
    end
    scenario 'InstagramをクリックしてInstagramアカウント情報へ遷移できる' do
      visit account_path(2)
      find('ul.nav a.Instagram_color').click
      expect(page).to have_current_path account_path(1)
      expect(page).to have_selector 'ul.nav .Instagram_btn'
      expect(page).not_to have_selector 'ul.nav .LINE_btn'
    end
    scenario 'ブランド分析をクリックしてブランド詳細画面へ正しく遷移できる' do
      visit account_path(1)
      click_on 'ブランド分析'
      expect(page).to have_current_path brand_path(1)
    end
  end

  context 'メディアごとにアカウント詳細表示を変える' do
    background do
      # 同一会社、同一ブランドのLINEアカウントを作成
      FactoryBot.create(:account, media: 'LINE',)
      FactoryBot.create(:daily_account_engagement, account_id: 2, line_follower: 200)
    end

    scenario 'Instagramアカウントでは、フォロワー数のみ表示' do
      visit account_path(1)
      expect(page).to have_content("フォロワー数：1,000")
      expect(page).to_not have_content("友だち数")
    end
    scenario 'Instagramアカウントでは、フォロワー数推移が表示' do
      visit account_path(1)
      expect(page).to have_content("フォロワー数推移")
      expect(page).to_not have_content("友だち数推移")
    end
    scenario 'LINEアカウントでは、フォロワー数と友だち数が表示' do
      visit account_path(2)
      expect(page).to have_content("フォロワー数：200")
      expect(page).to have_content("友だち数：1,000")
    end
    scenario 'LINEアカウントでは、友だち数の推移が表示' do
      visit account_path(2)
      expect(page).to have_content("友だち数推移")
      expect(page).to_not have_content("フォロワー数推移")
    end
  end

  feature '絞り込みフォームの動作' do
    background do
      @line_account = FactoryBot.create(:account, media: 'LINE')
      @insta_account = FactoryBot.create(:account, media: 'Instagram')
    end
    context 'LINEアカウント' do
      background do
        visit account_path(@line_account)
        find('span', text: '絞り込みフォーム').click
        sleep 0.5
      end
      context 'タイムラインタブ' do
        scenario '絞り込みをしてタイムラインタブへ遷移できる' do
          fill_in('search_text', with: 'text')
          within('.tab-pane') { click_on '絞り込み' }
          expect(all('a.active', text: 'タイムライン').length).to eq 1
        end
        scenario 'アカウントのフィールドが表示されていない' do
          expect(page).not_to have_selector('#search_account')
          expect(page).not_to have_content('アカウント名')
        end
        scenario 'メディアのフィールドが表示されていない' do
          expect(page).not_to have_selector('#media')
          expect(page).not_to have_content('SNS')
        end
        scenario '投稿タイプで 通常投稿 が選べる' do
          expect(page).to have_selector('option[value="normal_post"]')
        end
        scenario '並び替えで 投稿が新しい順, いいね数 が選べる' do
          expect(page).to have_selector('option[value="posted_at"]')
          expect(page).to have_selector('option[value="like"]')
        end
        context '投稿日時絞込みパーツ' do
          scenario '昨日を選択すると昨日の日付がセットされる' do
            click_on 'yesterday_filter'
            sleep 0.5
            expect(find('#start_date').value).to eq I18n.l((Time.current - 1.day).to_date)
            expect(find('#end_date').value).to eq I18n.l((Time.current - 1.day).to_date)
          end
          scenario '3日間を選択すると今日から3日間の日付がセットされる' do
            click_on 'three_days_filter'
            sleep 0.5
            expect(find('#start_date').value).to eq I18n.l((Time.current - 2.day).to_date)
            expect(find('#end_date').value).to eq I18n.l((Time.current).to_date)
          end
          scenario '一週間を選択すると今日から一週間の日付がセットされる' do
            click_on 'one_week_filter'
            sleep 0.5
            expect(find('#start_date').value).to eq I18n.l((Time.current - 6.day).to_date)
            expect(find('#end_date').value).to eq I18n.l((Time.current).to_date)
          end
          scenario '30日間を選択すると今日から30日間の日付がセットされる' do
            click_on '30_days_filter'
            sleep 0.5
            expect(find('#start_date').value).to eq I18n.l((Time.current - 29.day).to_date)
            expect(find('#end_date').value).to eq I18n.l((Time.current).to_date)
          end
          scenario '今月を選択すると今月の1日から今日までがセットされる' do
            click_on 'this_month_filter'
            sleep 0.5
            expect(find('#start_date').value).to eq I18n.l(Date.today.beginning_of_month)
            expect(find('#end_date').value).to eq I18n.l((Time.current).to_date)
          end
        end
      end
      context 'トークタブ' do
        background do
          find('a', text: 'トーク').click
          sleep 0.5
        end
        scenario '絞り込みをしてトークタブへ遷移できる' do
          fill_in('search_text', with: 'text')
          within('.tab-pane') { click_on '絞り込み' }
          expect(all('a.active', text: 'トーク').length).to eq 1
        end
        scenario 'アカウントのフィールドが表示されていない' do
          expect(page).not_to have_selector('#search_account')
          expect(page).not_to have_content('アカウント名')
        end
        scenario '投稿タイプで テキスト スタンプ 画像 動画 イメージマップ カルーセル が選べる' do
          expect(page).to have_selector('option[value="text"]')
          expect(page).to have_selector('option[value="stamp"]')
          expect(page).to have_selector('option[value="image"]')
          expect(page).to have_selector('option[value="video"]')
          expect(page).to have_selector('option[value="image_map"]')
          expect(page).to have_selector('option[value="carousel"]')
        end
        context '投稿日時絞込みパーツ' do
          scenario '昨日を選択すると昨日の日付がセットされる' do
            click_on 'talk_yesterday_filter'
            sleep 0.5
            expect(find('#talk_start_date').value).to eq I18n.l((Time.current - 1.day).to_date)
            expect(find('#talk_end_date').value).to eq I18n.l((Time.current - 1.day).to_date)
          end
          scenario '3日間を選択する今日から3日間の日付がセットされる' do
            click_on 'talk_three_days_filter'
            sleep 0.5
            expect(find('#talk_start_date').value).to eq I18n.l((Time.current - 2.day).to_date)
            expect(find('#talk_end_date').value).to eq I18n.l((Time.current).to_date)
          end
          scenario '一週間を選択すると今日から一週間の日付がセットされる' do
            click_on 'talk_one_week_filter'
            sleep 0.5
            expect(find('#talk_start_date').value).to eq I18n.l((Time.current - 6.day).to_date)
            expect(find('#talk_end_date').value).to eq I18n.l((Time.current).to_date)
          end
          scenario '30日間を選択すると今日から30日間の日付がセットされる' do
            click_on 'talk_30_days_filter'
            sleep 0.5
            expect(find('#talk_start_date').value).to eq I18n.l((Time.current - 29.day).to_date)
            expect(find('#talk_end_date').value).to eq I18n.l((Time.current).to_date)
          end
          scenario '今月を選択すると今月の1日から今日までがセットされる' do
            click_on 'talk_this_month_filter'
            sleep 0.5
            expect(find('#talk_start_date').value).to eq I18n.l(Date.today.beginning_of_month)
            expect(find('#talk_end_date').value).to eq I18n.l((Time.current).to_date)
          end
        end
      end
      context 'リッチメニュータブ' do
        background do
          find('a', text: 'リッチメニュー').click
          sleep 0.5
        end
        scenario '絞り込みをしてリッチメニュータブへ遷移できる' do
          fill_in('search_url', with: 'text')
          within('.tab-pane') { click_on '絞り込み' }
          expect(all('a.active', text: 'リッチメニュー').length).to eq 1
        end
        scenario 'アカウントのフィールドが表示されていない' do
          expect(page).not_to have_selector('#search_account')
          expect(page).not_to have_content('アカウント名')
        end
        # scenario '並び替えで 表示開始日が新しい順 が選べる' do # TODO: 現状、並び替えが一つしかないので、並び替えフィルターは表示していない。
          # expect(page).to have_selector('option[value="date_from"]')
        # end
        context '投稿日時絞込みパーツ' do
          scenario '昨日を選択すると昨日の日付がセットされる' do
            click_on 'richmenu_yesterday_filter'
            sleep 0.5
            expect(find('#richmenu_start_date').value).to eq I18n.l((Time.current - 1.day).to_date)
            expect(find('#richmenu_end_date').value).to eq I18n.l((Time.current - 1.day).to_date)
          end
          scenario '3日間を選択すると今日から3日間の日付がセットされる' do
            click_on 'richmenu_three_days_filter'
            sleep 0.5
            expect(find('#richmenu_start_date').value).to eq I18n.l((Time.current - 2.day).to_date)
            expect(find('#richmenu_end_date').value).to eq I18n.l((Time.current).to_date)
          end
          scenario '一週間を選択すると今日から一週間の日付がセットされる' do
            click_on 'richmenu_one_week_filter'
            sleep 0.5
            expect(find('#richmenu_start_date').value).to eq I18n.l((Time.current - 6.day).to_date)
            expect(find('#richmenu_end_date').value).to eq I18n.l((Time.current).to_date)
          end
          scenario '30日間を選択すると今日から30日間の日付がセットされる' do
            click_on 'richmenu_30_days_filter'
            sleep 0.5
            expect(find('#richmenu_start_date').value).to eq I18n.l((Time.current - 29.day).to_date)
            expect(find('#richmenu_end_date').value).to eq I18n.l((Time.current).to_date)
          end
          scenario '今月を選択すると今月の1日から今日までがセットされる' do
            click_on 'richmenu_this_month_filter'
            sleep 0.5
            expect(find('#richmenu_start_date').value).to eq I18n.l(Date.today.beginning_of_month)
            expect(find('#richmenu_end_date').value).to eq I18n.l((Time.current).to_date)
          end
        end
      end
    end
  end

  feature '絞り込み機能' do
    background do
      @line_account = FactoryBot.create(:account, media: 'LINE')
      FactoryBot.create(:post, posted_on: Date.today, media: "LINE", account_id: @line_account.id, text: "テスト文字列")
      FactoryBot.create(:post, posted_on: Date.today, media: "LINE", account_id: @line_account.id)

      FactoryBot.create(:talk_post)
      FactoryBot.create(:talk_post)
      FactoryBot.create(:talk_post_content, posted_at: Date.today, account_id: @line_account.id, text: "テスト文字列")
      FactoryBot.create(:talk_post_content, posted_at: Date.today, account_id: @line_account.id)

      FactoryBot.create(:rich_menu, account_id: @line_account.id, group_hash: "test_group_hash")
      FactoryBot.create(:rich_menu, account_id: @line_account.id)
      FactoryBot.create(:rich_menu_content, account_id: @line_account.id, url_hash: "lp_url_hash", group_hash: "test_group_hash")
      FactoryBot.create(:rich_menu_content, account_id: @line_account.id)
      FactoryBot.create(:lp_combined_url, url_hash: "lp_url_hash", combined_url: "http://test.example.com")
    end

    context "タイムラインタブ、現在のタブがタイムラインタブの場合" do
      background do
        visit account_path(@line_account, search_text: "テスト文字列")
        find('span', text: '絞り込みフォーム').click
      end
      example "絞り込みの条件が反映される" do
        expect(all('table#timeline_table tbody tr').size).to eq 1
        expect(find('table#timeline_table tbody tr td:nth-child(3)').text).to eq "テスト文字列"
      end
    end
    context "タイムラインタブ、現在のタブがタイムラインタブでない場合" do
      background do
        visit account_path(@line_account, search_text: "テスト文字列", current_tab: "talk")
      end
      example "絞り込みの条件が反映されず、期間のみで絞り込まれる" do
        click_on "タイムライン"
        sleep 0.5
        expect(all('table#timeline_table tbody tr').size).to eq 2
      end
    end

    context "トークタブ、現在のタブがトークタブの場合" do
      background do
        visit account_path(@line_account, search_text: "テスト文字列", current_tab: "talk")
      end
      example "絞り込みの条件が反映される" do
        expect(all('table#talk_content_table tbody tr').size).to eq 1
      end
    end
    context "トークタブ、現在のタブがトークタブでない場合" do
      background do
        visit account_path(@line_account, search_text: "テスト文字列", current_tab: nil)
      end
      example "絞り込みの条件が反映されず、期間のみで絞り込まれる" do
        click_on "トーク"
        sleep 0.5
        expect(all('table#talk_content_table tbody tr').size).to eq 2
      end
    end

    context "リッチメニュータブ、現在のタブがリッチメニュータブの場合" do
      background do
        visit account_path(@line_account, search_url: "http://test.example.com", current_tab: "rich_menu")
      end
      example "絞り込みの条件が反映される" do
        expect(all('table#richmenu_table tbody tr').size).to eq 1
      end
    end
    context "リッチメニュータブ、現在のタブがリッチメニュータブの場合" do
      background do
        visit account_path(@line_account, search_url: "http://test.example.com", current_tab: "talk")
      end
      example "絞り込みの条件が反映されず、期間のみで絞り込まれる" do
        click_on "リッチメニュー"
        sleep 0.5
        expect(all('table#richmenu_table tbody tr').size).to eq 2
      end
    end
  end

  feature "フォロワー数推移グラフのテスト" do
    background do
      @instagram_account = FactoryBot.create(:account, media: 'Instagram')
      FactoryBot.create(:daily_account_engagement, date: Date.today - 1.days, follower: 50, account_id: @instagram_account.id)
      FactoryBot.create(:daily_account_engagement, date: Date.today, follower: 100, account_id: @instagram_account.id)
      visit account_path(@instagram_account)
    end
    example "フォロワー数推移グラフが表示されている" do
      expect(page).to have_selector('canvas#followerChart')
    end
    example "アイコンが表示されている" do
      FactoryBot.create(:post, posted_on: Date.today, media: "Instagram", account_id: @instagram_account.id)
      visit current_path
      expect(page).to have_selector('.Instagram_circle_icon')
    end
    example "アイコンに投稿数が表示される" do
      FactoryBot.create(:post, posted_on: Date.today.beginning_of_month, media: "Instagram", account_id: @instagram_account.id)
      FactoryBot.create(:post, posted_on: Date.today.beginning_of_month, media: "Instagram", post_type: "story", account_id: @instagram_account.id)
      FactoryBot.create(:post, posted_on: Date.today.beginning_of_month + 1.days, media: "Instagram", account_id: @instagram_account.id)
      visit current_path
      expect(find('.Instagram_circle_icon.Instagram_follower_transition_icon0').text).to eq "2"
      expect(find('.Instagram_circle_icon.Instagram_follower_transition_icon1').text).to eq "1"
    end
    example "投稿がない日はアイコンが表示されない" do
      expect(page).not_to have_css('.Instagram_circle_icon.Instagram_follower_transition_icon0')
    end
    example "アイコンをクリックするとそのメディアのアカウント詳細画面に遷移し、パラメータにその日付がstart_date, end_dateとして設定されている" do
      FactoryBot.create(:post, posted_on: Date.today.beginning_of_month, media: "Instagram", account_id: @instagram_account.id)
      visit current_path
      find('.Instagram_circle_icon.Instagram_follower_transition_icon0').click
      expect(page).to have_current_path(account_path(@instagram_account.id) + "?end_date=#{Date.today.beginning_of_month.strftime}&start_date=#{Date.today.beginning_of_month.strftime}")
    end
    example "期間を絞り込むとその期間のブランドリフトのみが表示される" do
      FactoryBot.create(:daily_account_engagement, date: Date.new(2021,1,1), follower: 50, account_id: @instagram_account.id)
      FactoryBot.create(:daily_account_engagement, date: Date.new(2021,1,2), follower: 50, account_id: @instagram_account.id)
      FactoryBot.create(:post, posted_on: Date.new(2021,1,1), media: "Instagram", account_id: @instagram_account.id)
      select '2021年1月', from: 'follower_transition_month'
      click_on('絞り込み')
      expect(find('.Instagram_circle_icon.Instagram_follower_transition_icon0').text).to eq "1"
    end
    example "デフォルトの状態だと期間は今月になっている" do
      FactoryBot.create(:daily_account_engagement, date: Date.today.beginning_of_month, follower: 50, account_id: @instagram_account.id)
      FactoryBot.create(:post, posted_on: Date.today.beginning_of_month, media: "Instagram", account_id: @instagram_account.id)
      visit current_path
      expect(find('.Instagram_circle_icon.Instagram_follower_transition_icon0').text).to eq "1"
      expect(page).to have_select('follower_transition_month', selected: "#{Date.today.year}年#{Date.today.month}月")
    end
  end

  feature "お気に入り機能" do
    context "お気に入り登録、削除" do
      background do
        @favorite_test_account = FactoryBot.create(:account)
        visit account_path(@favorite_test_account)
      end
      scenario "ボタンクリックでお気に入り登録/削除の切り替え" do
        expect(Favorite.all.size).to eq(0)
        find('#favorite_2').click
        sleep 1
        expect(Favorite.all.size).to eq(1)
        expect(Favorite.first.account).to eq(@favorite_test_account)
        find('#favorite_2').click
        sleep 1
        expect(Favorite.all.size).to eq(0)
      end
    end
  end
end
