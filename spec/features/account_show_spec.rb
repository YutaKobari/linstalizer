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
    scenario 'SNSをクリックするとSNSで絞り込んだアカウント一覧表示に遷移' do
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
    scenario 'ブランドTOPIXをクリックしてブランド詳細画面へ正しく遷移できる' do
      visit account_path(1)
      click_on 'ブランドTOPIX'
      expect(page).to have_current_path brand_path(1)
    end
  end

  context 'SNSごとにアカウント詳細表示を変える' do
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
        scenario 'SNSのフィールドが表示されていない' do
          expect(page).not_to have_selector('#media')
          expect(page).not_to have_content('SNS')
        end
        scenario '投稿タイプで タイムライン投稿 が選べる' do
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

        context '時間帯での絞り込み' do
          background do
            FactoryBot.create(:post, posted_at: '2021/03/04 13:00:01 JTC', hour: 13, account_id: @line_account.id)
            FactoryBot.create(:post, posted_at: '2021/03/14 23:59:59 JTC', hour: 23, account_id: @line_account.id)
            FactoryBot.create(:post, posted_at: '2021/03/17 15:00:00 JTC', hour: 15, account_id: @line_account.id)
            FactoryBot.create(:post, posted_at: '2021/04/04 00:00:00 JTC', hour:  0, account_id: @line_account.id)
          end

          context '時間帯絞込みパーツ' do
            scenario '午前を選択すると0時台〜11時台' do
              click_on 'am_filter'
              sleep 0.5
              expect(find('#hour_start').value).to eq "0"
              expect(find('#hour_end').value).to eq "11"
            end
            scenario '午後を選択すると12時台〜23時台' do
              click_on 'pm_filter'
              sleep 0.5
              expect(find('#hour_start').value).to eq "12"
              expect(find('#hour_end').value).to eq "23"
            end
            scenario '朝を選択すると5時台〜10時台' do
              click_on 'morning_filter'
              sleep 0.5
              expect(find('#hour_start').value).to eq "5"
              expect(find('#hour_end').value).to eq "10"
            end
            scenario '昼を選択すると11時台〜14時台' do
              click_on 'daytime_filter'
              sleep 0.5
              expect(find('#hour_start').value).to eq "11"
              expect(find('#hour_end').value).to eq "14"
            end
            scenario '夕を選択すると15時台〜18時台' do
              click_on 'evening_filter'
              sleep 0.5
              expect(find('#hour_start').value).to eq "15"
              expect(find('#hour_end').value).to eq "18"
            end
            scenario '夜を選択すると19時台〜23時台' do
              click_on 'night_filter'
              sleep 0.5
              expect(find('#hour_start').value).to eq "19"
              expect(find('#hour_end').value).to eq "23"
            end
            scenario '深夜を選択すると0時台〜4時台' do
              click_on 'midnight_filter'
              sleep 0.5
              expect(find('#hour_start').value).to eq "0"
              expect(find('#hour_end').value).to eq "4"
            end
          end

          scenario "指定時刻の間の投稿のみが表示される" do
            select "13時台", from: 'hour_start'
            select "15時台", from: 'hour_end'
            find("#post_form_button").click
            expect(all('tbody tr').length).to eq 2

            select "0時台", from: 'hour_start'
            select "23時台", from: 'hour_end'
            find("#post_form_button").click
            expect(all('tbody tr').length).to eq 4
          end

          scenario "開始時より終了時が前だとモーダルをだし、絞り込みをしない" do
            visit account_path(@line_account)
            expect(all('tbody tr').length).to eq 4
            expect(page).to_not have_content('開始時刻は終了時刻より前にしてください')

            find('span', text: '絞り込みフォーム').click
            select "15時台", from: 'hour_start'
            select "1時台", from: 'hour_end'
            find("#post_form_button").click
            expect(page).to have_content('開始時刻は終了時刻より前にしてください')
            #FIXME 以下bitbucketで落ちる。pendingを入れてもbitbucketでerrorが出されるのでコメントアウトしている。
            # find("#modal_close").click
            # expect(page).to_not have_content('開始時刻は終了時刻より前にしてください')
            # expect(all('tbody tr').length).to eq 4
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
        context '時間帯で絞り込みを行う' do
          background do
            FactoryBot.create(:talk_post, hour: 0, account_id: @line_account.id) do |talk_post|
              FactoryBot.create(:talk_post_content, posted_at: '2021/03/01 00:00:00 JTC', talk_group_hash: talk_post.talk_group_hash, account_id: talk_post.account_id)
            end
            FactoryBot.create(:talk_post, hour: 13, account_id: @line_account.id) do |talk_post|
              FactoryBot.create(:talk_post_content, posted_at: '2021/03/04 13:00:00 JTC', talk_group_hash: talk_post.talk_group_hash, account_id: talk_post.account_id)
            end
            FactoryBot.create(:talk_post, hour: 15, account_id: @line_account.id) do |talk_post|
              FactoryBot.create(:talk_post_content, posted_at: '2021/03/06 15:59:59 JTC', talk_group_hash: talk_post.talk_group_hash, account_id: talk_post.account_id)
            end
            FactoryBot.create(:talk_post, hour: 23, account_id: @line_account.id) do |talk_post|
              FactoryBot.create(:talk_post_content, posted_at: '2021/03/07 23:00:01 JTC', talk_group_hash: talk_post.talk_group_hash, account_id: talk_post.account_id)
            end
          end

          context '時間帯絞込みパーツ' do
            scenario '午前を選択すると0時台〜11時台' do
              click_on 'talk_am_filter'
              sleep 0.5
              expect(find('#talk_hour_start').value).to eq "0"
              expect(find('#talk_hour_end').value).to eq "11"
            end
            scenario '午後を選択すると12時台〜23時台' do
              click_on 'talk_pm_filter'
              sleep 0.5
              expect(find('#talk_hour_start').value).to eq "12"
              expect(find('#talk_hour_end').value).to eq "23"
            end
            scenario '朝を選択すると5時台〜10時台' do
              click_on 'talk_morning_filter'
              sleep 0.5
              expect(find('#talk_hour_start').value).to eq "5"
              expect(find('#talk_hour_end').value).to eq "10"
            end
            scenario '昼を選択すると11時台〜14時台' do
              click_on 'talk_daytime_filter'
              sleep 0.5
              expect(find('#talk_hour_start').value).to eq "11"
              expect(find('#talk_hour_end').value).to eq "14"
            end
            scenario '夕を選択すると15時台〜18時台' do
              click_on 'talk_evening_filter'
              sleep 0.5
              expect(find('#talk_hour_start').value).to eq "15"
              expect(find('#talk_hour_end').value).to eq "18"
            end
            scenario '夜を選択すると19時台〜23時台' do
              click_on 'talk_night_filter'
              sleep 0.5
              expect(find('#talk_hour_start').value).to eq "19"
              expect(find('#talk_hour_end').value).to eq "23"
            end
            scenario '深夜を選択すると0時台〜4時台' do
              click_on 'talk_midnight_filter'
              sleep 0.5
              expect(find('#talk_hour_start').value).to eq "0"
              expect(find('#talk_hour_end').value).to eq "4"
            end
          end

          scenario "指定時刻の間の投稿のみが表示される" do
            select "13時", from: 'hour_start'
            select "15時", from: 'hour_end'
            find("#talk_post_form_button").click
            expect(all('tbody tr').length).to eq 2

            select "0時台", from: 'hour_start'
            select "23時台", from: 'hour_end'
            find("#talk_post_form_button").click
            expect(all('tbody tr').length).to eq 4
          end

          scenario "開始時より終了時が前だとモーダルをだし、絞り込みをしない" do
            visit account_path(@line_account)
            find('a', text: 'トーク').click
            sleep 0.5
            expect(all('tbody tr').length).to eq 4
            expect(page).to_not have_content('開始時刻は終了時刻より前にしてください')

            find('span', text: '絞り込みフォーム').click
            select "15時台", from: 'hour_start'
            select "1時台", from: 'hour_end'
            find("#talk_post_form_button").click
            expect(page).to have_content('開始時刻は終了時刻より前にしてください')
            #FIXME 以下bitbucketで落ちる。pendingを入れてもbitbucketでerrorが出されるのでコメントアウトしている。
            # find("#modal_close").click
            # expect(page).to_not have_content('開始時刻は終了時刻より前にしてください')
            # expect(all('tbody tr').length).to eq 4
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
      @default_aggregation_start = 29.days.ago.to_date # グラフ表示デフォルトの最初の日
      @default_aggregation_end = Date.today # グラフ表示デフォルトの最後の日
      @instagram_account = FactoryBot.create(:account, media: 'Instagram')
      FactoryBot.create(:daily_account_engagement, date: Date.today - 1.days, follower: 50, account_id: @instagram_account.id)
      FactoryBot.create(:daily_account_engagement, date: Date.today, follower: 100, account_id: @instagram_account.id)
      visit account_path(@instagram_account)
    end
    example "フォロワー数推移グラフが表示されている" do
      expect(page).to have_selector('canvas#follower-transition-canvas')
    end
    example "フォロワー数増減グラフが表示されている" do
      expect(page).to have_selector('canvas#follower-increment-canvas')
    end
    example "アイコンが表示されている" do
      FactoryBot.create(:post, posted_on: 1.days.ago, media: "Instagram", account_id: @instagram_account.id)
      visit current_path
      expect(all('.Instagram_circle_icon').size).to eq(2) # 2個のグラフにそれぞれある
    end
    example "アイコンに投稿数が表示される" do
      FactoryBot.create(:post, :feed, posted_on: @default_aggregation_start, account_id: @instagram_account.id)
      FactoryBot.create(:post, :story, posted_on: @default_aggregation_start, account_id: @instagram_account.id)
      visit current_path
      # 二つのグラフにそれぞれ②が表示されているかを見る
      all('.Instagram_circle_icon.Instagram_follower_transition_icon0').each do |elem|
        expect(elem.text).to eq "2"
      end
    end
    example "投稿がない日はアイコンが表示されない" do
      expect(page).not_to have_css('.Instagram_circle_icon.Instagram_follower_transition_icon0')
    end
    example "アイコンクリックすると投稿一覧タブのstart_date, end_dateがその日付として絞り込まれ、グラフは保持される" do
      FactoryBot.create(:post, posted_on: @default_aggregation_end, media: "Instagram", account_id: @instagram_account.id)
      click_on 'graph_one_week_aggregation'
      click_on('絞り込み')
      all('.Instagram_circle_icon.Instagram_follower_transition_icon6').first.click
      click_date = @default_aggregation_end
      expect(page).to have_current_path(account_path(@instagram_account.id, start_date: click_date, end_date: click_date, graph_aggregated_to: click_date.strftime("%Y/%m/%d"), graph_aggregated_from: (click_date - 6.days).strftime("%Y/%m/%d")))
    end
    example "期間を絞り込むとその期間のブランドTOPIXのみが表示される" do
      FactoryBot.create(:daily_account_engagement, date: Date.new(2021,3,1), follower: 50, account_id: @instagram_account.id)
      FactoryBot.create(:daily_account_engagement, date: Date.new(2021,3,2), follower: 50, account_id: @instagram_account.id)
      FactoryBot.create(:post, :feed, posted_on: Date.new(2021,03,01), account_id: @instagram_account.id)
      FactoryBot.create(:post, :feed, posted_on: Date.new(2021,03,10), account_id: @instagram_account.id)
      fill_in 'graph_aggregated_from', with: '2021/03/01'
      fill_in 'graph_aggregated_to', with: '2021/03/02'
      click_on('絞り込み')
      all('.Instagram_circle_icon.Instagram_follower_transition_icon0').each do |elem|
        expect(elem.text).to eq "1"
      end
    end
    example "デフォルトの状態だと期間は直近30日間になっている" do
      FactoryBot.create(:daily_account_engagement, date: @default_aggregation_start, follower: 50, account_id: @instagram_account.id)
      FactoryBot.create(:post, posted_on: @default_aggregation_start, media: "Instagram", account_id: @instagram_account.id)
      FactoryBot.create(:post, posted_on: @default_aggregation_end, media: "Instagram", account_id: @instagram_account.id)
      visit current_path
      all('.Instagram_circle_icon.Instagram_follower_transition_icon0').each do |elem|
        expect(elem.text).to eq "1"
      end
      all('.Instagram_circle_icon.Instagram_follower_transition_icon29').each do |elem|
        expect(elem.text).to eq "1"
      end
      expect(page).to have_field('graph_aggregated_from', placeholder: I18n.l(@default_aggregation_start))
      expect(page).to have_field('graph_aggregated_to', placeholder: I18n.l(@default_aggregation_end))
    end
  end

  feature "ピンアカ機能" do
    context "ピンアカ登録、削除" do
      background do
        @favorite_test_account = FactoryBot.create(:account)
        visit account_path(@favorite_test_account)
      end
      scenario "ボタンクリックでピンアカ登録/削除の切り替え" do
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
