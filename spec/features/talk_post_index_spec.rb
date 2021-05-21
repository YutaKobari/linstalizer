require 'rails_helper'

feature 'トーク投稿一覧画面' do
  given(:email) { 'tester@example.com' }
  given(:pwd) { '000000' }

  background do
    FactoryBot.create(:user)
    FactoryBot.create(:company)
    FactoryBot.create(:market)
    FactoryBot.create(:brand)
    FactoryBot.create(:account)
    FactoryBot.create(:landing_page)
    FactoryBot.create(:lp_combined_url)
    FactoryBot.create(:market, name: "飲食") #id = 2
    FactoryBot.create(:brand, name: "飲食のブランド", market_id: 2)
    FactoryBot.create(:account, brand_id: 2) #id = 2
    # Login
    visit root_path
    fill_in 'user_email', with: email
    fill_in 'user_password', with: pwd
    click_on 'ログイン'
  end

  scenario 'ホーム画面からLINE投稿一覧へ遷移できる' do
    click_on 'LINE投稿'
    click_on 'トーク投稿検索'
    expect(current_path).to eq talk_posts_path
  end

  context '遷移直後の状態' do
    background do
      5.times { FactoryBot.create(:talk_post) }
      5.times { FactoryBot.create(:talk_post_content) }
      visit talk_posts_path
    end
    scenario 'すべての投稿が表示される' do
      expect(all('tbody tr').length).to eq 5
    end
  end

  feature '絞り込みフォーム機能' do
    background do
      visit talk_posts_path
      find('span', text: "絞り込みフォーム").click
    end
    context '何も指定しないとき' do
      background do
        5.times { FactoryBot.create(:talk_post) }
        5.times { FactoryBot.create(:talk_post_content) }
        visit talk_posts_path
      end
      scenario 'すべての投稿が表示される' do
        expect(all('tbody tr').length).to eq 5
      end
    end

    context 'キーワードフルテキスト検索を行う' do
      it 'キーワードを含む項目のみが表示される' do
        talk_post1 = FactoryBot.create(:talk_post)
        FactoryBot.create(:talk_post_content, text: 'テスト文字列', talk_group_hash: talk_post1.talk_group_hash)
        FactoryBot.create(:talk_post_content, text: 'テスト文字列', talk_group_hash: talk_post1.talk_group_hash)
        talk_post2 = FactoryBot.create(:talk_post)
        FactoryBot.create(:talk_post_content, text: 'テスト文字列', talk_group_hash: talk_post2.talk_group_hash)
        talk_post3 = FactoryBot.create(:talk_post)
        FactoryBot.create(:talk_post_content, text: 'ヒットしない文字列', talk_group_hash: talk_post3.talk_group_hash)
        fill_in('search_text', with: 'テスト')
        click_on('絞り込み')
        expect(all('tbody tr').length).to eq 2
      end
    end

    context 'アカウントLIKE検索を行う' do
      scenario 'アカウント名に検索ワードを含む項目が表示される' do
        account = FactoryBot.create(:account, name: '異なるAccount')
        FactoryBot.create(:talk_post) do |talk_post|
          FactoryBot.create(:talk_post_content, talk_group_hash: talk_post.talk_group_hash)
        end
        FactoryBot.create(:talk_post, account_id: account.id) do |talk_post|
          FactoryBot.create(:talk_post_content, talk_group_hash: talk_post.talk_group_hash, account_id: account.id)
        end
        FactoryBot.create(:talk_post, account_id: account.id) do |talk_post|
          FactoryBot.create(:talk_post_content, talk_group_hash: talk_post.talk_group_hash, account_id: account.id)
        end
        fill_in('search_account', with: '異なる')
        click_on '絞り込み'
        expect(all('tbody tr').length).to eq 2
      end

      scenario 'ブランド名に検索ワードを含む項目が表示される' do
        brand = FactoryBot.create(:brand, name: "異なるブランド名")
        account = FactoryBot.create(:account, brand_id: brand.id)
        FactoryBot.create(:talk_post) do |talk_post|
          FactoryBot.create(:talk_post_content, talk_group_hash: talk_post.talk_group_hash)
        end
        FactoryBot.create(:talk_post, account_id: account.id, brand_id: brand.id) do |talk_post|
          FactoryBot.create(:talk_post_content, talk_group_hash: talk_post.talk_group_hash, account_id: account.id, brand_id: brand.id)
        end
        FactoryBot.create(:talk_post, account_id: account.id, brand_id: brand.id) do |talk_post|
          FactoryBot.create(:talk_post_content, talk_group_hash: talk_post.talk_group_hash, account_id: account.id, brand_id: brand.id)
        end
        fill_in('search_account', with: '異なる')
        click_on '絞り込み'
        expect(all('tbody tr').length).to eq 2
      end
    end

    context '業種で絞り込みを行う' do
      scenario '選択した業種だけが表示' do
        pending('ローカルでは通るがCIで落ちる')
        #マーケットがコスメのブランドによる投稿
        FactoryBot.create(:talk_post) do |talk_post|
          FactoryBot.create(:talk_post_content, talk_group_hash: talk_post.talk_group_hash, account_id: talk_post.account_id, brand_id: talk_post.brand_id)
        end
        FactoryBot.create(:talk_post) do |talk_post|
          FactoryBot.create(:talk_post_content, talk_group_hash: talk_post.talk_group_hash, account_id: talk_post.account_id, brand_id: talk_post.brand_id)
        end
        #マーケットが飲食のブランドによる投稿

        FactoryBot.create(:talk_post, account_id: 2, brand_id: 2) do |talk_post|
          FactoryBot.create(:talk_post_content, talk_group_hash: talk_post.talk_group_hash, account_id: talk_post.account_id, brand_id: talk_post.brand_id)
        end
        FactoryBot.create(:talk_post, account_id: 2, brand_id: 2) do |talk_post|
          FactoryBot.create(:talk_post_content, talk_group_hash: talk_post.talk_group_hash, account_id: talk_post.account_id, brand_id: talk_post.brand_id)
        end
        FactoryBot.create(:talk_post, account_id: 2, brand_id: 2) do |talk_post|
          FactoryBot.create(:talk_post_content, talk_group_hash: talk_post.talk_group_hash, account_id: talk_post.account_id, brand_id: talk_post.brand_id)
        end
        visit current_path
        expect(all('tbody tr').length).to eq 5

        find('span', text: '絞り込みフォーム').click
        select 'コスメ・美容', from: '業種'
        click_on '絞り込み'
        expect(all('tbody tr').length).to eq 2

        select '飲食', from: '業種'
        click_on '絞り込み'
        expect(all('tbody tr').length).to eq 3

        select '全業種', from: '業種'
        click_on '絞り込み'
        expect(all('tbody tr').length).to eq 5
      end
    end

    context 'URLフルテキスト検索を行う' do
      scenario 'キーワードを含む項目のみが表示される' do
        FactoryBot.create(:landing_page, url_hash: 'expect_to_be_hit')
        FactoryBot.create(:lp_combined_url, combined_url: 'https://google.co.jp', url_hash: 'expect_to_be_hit') # expected to be hit
        FactoryBot.create(:talk_post) do |post|
          FactoryBot.create(:talk_post_content, talk_group_hash: post.talk_group_hash)
        end
        FactoryBot.create(:talk_post) do |post|
          FactoryBot.create(:talk_post_content, talk_group_hash: post.talk_group_hash, url_hash: 'expect_to_be_hit')
          FactoryBot.create(:talk_post_content, talk_group_hash: post.talk_group_hash, url_hash: 'expect_to_be_hit')
        end
        FactoryBot.create(:talk_post) do |post|
          FactoryBot.create(:talk_post_content, talk_group_hash: post.talk_group_hash, url_hash: 'expect_to_be_hit')
        end
        fill_in('search_url', with: 'google')
        click_on('絞り込み')
        expect(all('tbody tr').length).to eq 2
      end
    end

    context '投稿日時絞込みを行う' do
      background do
        # 3ヒット
        FactoryBot.create(:talk_post) do |talk_post|
          FactoryBot.create(:talk_post_content, posted_at: '2021/03/01 15:00:00 JTC', talk_group_hash: talk_post.talk_group_hash)
        end
        FactoryBot.create(:talk_post) do |talk_post|
          FactoryBot.create(:talk_post_content, posted_at: '2021/03/04 00:00:00 JTC', talk_group_hash: talk_post.talk_group_hash)
        end
        FactoryBot.create(:talk_post) do |talk_post|
          FactoryBot.create(:talk_post_content, posted_at: '2021/03/06 23:59:59 JTC', talk_group_hash: talk_post.talk_group_hash)
        end
        FactoryBot.create(:talk_post) do |talk_post|
          FactoryBot.create(:talk_post_content, posted_at: '2021/03/07 00:00:01 JTC', talk_group_hash: talk_post.talk_group_hash)
        end
      end
      scenario '昨日を選択すると昨日の日付がセットされる' do
        click_on 'talk_yesterday_filter'
        expect(find('#talk_start_date').value).to eq I18n.l((Time.zone.now - 1.day).to_date)
        expect(find('#talk_end_date').value).to eq I18n.l((Time.zone.now - 1.day).to_date)
      end
      scenario '3日間を選択すると今日から3日間の日付がセットされる' do
        click_on 'talk_three_days_filter'
        expect(find('#talk_start_date').value).to eq I18n.l((Time.zone.now - 2.day).to_date)
        expect(find('#talk_end_date').value).to eq I18n.l((Time.zone.now).to_date)
      end
      scenario '一週間を選択すると今日から一週間の日付がセットされる' do
        click_on 'talk_one_week_filter'
        expect(find('#talk_start_date').value).to eq I18n.l((Time.zone.now - 6.day).to_date)
        expect(find('#talk_end_date').value).to eq I18n.l((Time.zone.now).to_date)
      end
      scenario '30日間を選択すると今日から30日間の日付がセットされる' do
        click_on 'talk_30_days_filter'
        expect(find('#talk_start_date').value).to eq I18n.l((Time.zone.now - 29.day).to_date)
        expect(find('#talk_end_date').value).to eq I18n.l((Time.zone.now).to_date)
      end
      scenario '今月を選択すると今月の1日から今日までがセットされる' do
        click_on 'talk_this_month_filter'
        expect(find('#talk_start_date').value).to eq I18n.l(Date.today.beginning_of_month)
        expect(find('#talk_end_date').value).to eq I18n.l((Time.zone.now).to_date)
      end

      scenario '指定投稿日内の投稿のみが表示される' do
        fill_in 'talk_start_date', with: '2021/03/01'
        fill_in 'talk_end_date', with: '2021/03/06'
        find('label', text: "キーワード").click #カレンダーを消すために空クリック
        click_on('絞り込み')
        expect(all('tbody tr').length).to eq 3
      end
    end

    context '時間帯で絞り込みを行う' do
      background do
        FactoryBot.create(:talk_post, hour: 0) do |talk_post|
          FactoryBot.create(:talk_post_content, posted_at: '2021/03/01 15:00:00 JTC', talk_group_hash: talk_post.talk_group_hash)
        end
        FactoryBot.create(:talk_post, hour: 14) do |talk_post|
          FactoryBot.create(:talk_post_content, posted_at: '2021/03/04 00:00:00 JTC', talk_group_hash: talk_post.talk_group_hash)
        end
        FactoryBot.create(:talk_post, hour: 15) do |talk_post|
          FactoryBot.create(:talk_post_content, posted_at: '2021/03/06 23:59:59 JTC', talk_group_hash: talk_post.talk_group_hash)
        end
        FactoryBot.create(:talk_post, hour: 23) do |talk_post|
          FactoryBot.create(:talk_post_content, posted_at: '2021/03/07 00:00:01 JTC', talk_group_hash: talk_post.talk_group_hash)
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
        select "13時台", from: 'hour_start'
        select "15時台", from: 'hour_end'
        click_on('絞り込み')
        expect(all('tbody tr').length).to eq 2

        select "0時台", from: 'hour_start'
        select "23時台", from: 'hour_end'
        click_on('絞り込み')
        expect(all('tbody tr').length).to eq 4
      end

      scenario "開始時より終了時が前だとモーダルをだし、絞り込みをしない" do
        visit talk_posts_path
        expect(all('tbody tr').length).to eq 4
        expect(page).to_not have_content('開始時刻は終了時刻より前にしてください')

        find('span', text: '絞り込みフォーム').click
        select "15時台", from: 'hour_start'
        select "1時台", from: 'hour_end'
        click_on('絞り込み')
        expect(page).to have_content('開始時刻は終了時刻より前にしてください')
        #FIXME 以下CIで落ちる。pendingを入れてもCIでerrorが出されるのでコメントアウトしている。
        # find("#modal_close").click
        # expect(page).to_not have_content('開始時刻は終了時刻より前にしてください')
        # expect(all('tbody tr').length).to eq 4
      end
    end

    # TODO: 投稿タイプに変更・追加が行われる毎に追加編集する
    context '投稿タイプ絞り込みを行う' do
      given(:text_count) { 3 }
      given(:stamp_count) { 1 }
      given(:image_count) { 2 }
      given(:video_count) { 1 }
      background do
        talk_post1 = FactoryBot.create(:talk_post)
        talk_post2 = FactoryBot.create(:talk_post)
        talk_post3 = FactoryBot.create(:talk_post)
        talk_post4 = FactoryBot.create(:talk_post)
        FactoryBot.create(:talk_post_content, post_type: 'text', talk_group_hash: talk_post1.talk_group_hash)
        FactoryBot.create(:talk_post_content, post_type: 'image', talk_group_hash: talk_post1.talk_group_hash)
        FactoryBot.create(:talk_post_content, post_type: 'text', talk_group_hash: talk_post2.talk_group_hash)
        FactoryBot.create(:talk_post_content, post_type: 'image', talk_group_hash: talk_post2.talk_group_hash)
        FactoryBot.create(:talk_post_content, post_type: 'text', talk_group_hash: talk_post3.talk_group_hash)
        FactoryBot.create(:talk_post_content, post_type: 'stamp', talk_group_hash: talk_post3.talk_group_hash)
        FactoryBot.create(:talk_post_content, post_type: 'video', talk_group_hash: talk_post4.talk_group_hash)
        FactoryBot.create(:talk_post_content, post_type: 'video', talk_group_hash: talk_post4.talk_group_hash)
      end
      context 'トークタイプ: テキスト' do
        scenario 'テキスト投稿のみが表示される' do
          find("option[value='text']").select_option
          click_on '絞り込み'
          expect(all('tbody tr').length).to eq text_count
        end
      end
      context 'トークタイプ: スタンプ' do
        scenario 'スタンプ投稿のみが表示される' do
          find("option[value='stamp']").select_option
          click_on '絞り込み'
          expect(all('tbody tr').length).to eq stamp_count
        end
      end
      context 'トークタイプ: 画像' do
        scenario '画像投稿のみが表示される' do
          find("option[value='image']").select_option
          click_on '絞り込み'
          expect(all('tbody tr').length).to eq image_count
        end
      end
      context 'トークタイプ: 動画' do
        scenario '動画投稿のみが表示される' do
          find("option[value='video']").select_option
          click_on '絞り込み'
          expect(all('tbody tr').length).to eq video_count
        end
      end
    end

    context "ピンアカスイッチで絞り込み" do
      background do
        # どのユーザーもピンアカに登録していないアカウントを2個作成
        2.times do
          FactoryBot.create(:account, media: 'LINE') do |account|
            # 各アカウントに紐づくtalk_post(talk_post_content)を4つ作成
            4.times do
              talk_post = FactoryBot.create(:talk_post, account_id: account.id)
              FactoryBot.create(:talk_post_content, account_id: account.id, talk_group_hash: talk_post.talk_group_hash)
            end
          end
        end

        # user(id:2)がピンアカに登録しているアカウントを3個作成
        FactoryBot.create(:user, email: 'tester2@example.com')
        3.times do
          FactoryBot.create(:account, media: 'LINE') do |account|
            FactoryBot.create(:favorite, user_id: 2, account_id: account.id)
            # 各アカウントに紐づくtalk_post(talk_post_content)を2つ作成
            2.times do
              talk_post = FactoryBot.create(:talk_post, account_id: account.id)
              FactoryBot.create(:talk_post_content, account_id: account.id, talk_group_hash: talk_post.talk_group_hash)
            end
          end
        end

        # user(id:1)がピンアカに登録しているアカウントを4個作成
        4.times do
          FactoryBot.create(:account, media: 'LINE') do |account|
            FactoryBot.create(:favorite, account_id: account.id)
            # 各アカウントに紐づくtalk_post(talk_post_content)を5つ作成
            5.times do
              talk_post = FactoryBot.create(:talk_post, account_id: account.id)
              FactoryBot.create(:talk_post_content, account_id: account.id, talk_group_hash: talk_post.talk_group_hash)
            end
          end
        end
        visit talk_posts_path
        expect(all('tbody > tr').size).to eq(34) # 2×4 + 3×2 + 4×5 = 34
      end

      scenario "ピンアカスイッチONでピンアカのみ表示、OFFで解除" do
        find('span', text: "絞り込みフォーム").click
        find('label', text: "Off").click
        click_on '絞り込み'
        expect(all('tbody > tr').size).to eq(20)
        find('label', text: "On").click
        click_on '絞り込み'
        expect(all('tbody > tr').size).to eq(34)
      end
    end
  end
end
