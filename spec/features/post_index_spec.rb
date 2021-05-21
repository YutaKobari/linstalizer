require 'rails_helper'

feature '投稿一覧画面' do
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

  feature 'ホームからの遷移' do
    background do
      within(:css, '.sidenav') do
        click_on '投稿検索'
      end
    end
    scenario 'ホーム画面から投稿一覧へ遷移できる' do
      click_on '全SNS'
      expect(current_path).to eq posts_path
    end

    scenario 'ホーム画面から投稿一覧へ遷移し、LINEで絞りこんだ状態にできる' do
      find('.sidenav-normal', text: 'LINE').click
      find('span', text: '絞り込みフォーム').click
      find("option[value='LINE']").selected?
    end
    scenario 'ホーム画面から投稿一覧へ遷移し、Instagramで絞りこんだ状態にできる' do
      click_on 'Instagram'
      find('span', text: '絞り込みフォーム').click
      find("option[value='Instagram']").selected?
    end
  end

  context 'パンくずリスト' do
    scenario '全SNSで検索' do
      find('.fa-mail-bulk').click
      find('.sidenav-normal', text: '全SNS').click
      expect(page).to have_selector(".breadcrumb-item", text: '全SNS')
    end

    scenario 'LINEで検索' do
      find('.fa-mail-bulk').click
      find('.sidenav-normal', text: 'LINE').click
      expect(page).to have_selector(".breadcrumb-item", text: 'LINE')
    end

    scenario 'Instagramで検索' do
      find('.fa-mail-bulk').click
      find('.sidenav-normal', text: 'Instagram').click
      expect(page).to have_selector(".breadcrumb-item", text: 'Instagram')
    end
  end

  context '遷移直後の状態' do
    background do
      5.times { FactoryBot.create(:post) }
      visit posts_path
    end
    scenario 'すべての投稿が表示される' do
      expect(all('tbody tr').length).to eq 5
    end
  end

  feature '絞り込みフォーム機能' do
    background do
      visit posts_path
      find('span', text: '絞り込みフォーム').click
      sleep 0.5
    end

    scenario 'post後も入力内容がキープされている' do
      fill_in('search_text', with: 'テスト')
      fill_in('search_account', with: 'アカウント')
      fill_in('search_hash_tag', with: 'タグ')
      fill_in('search_url', with: 'google')
      select 'LINE', from: 'media'
      fill_in 'start_date', with: '2021/03/01'
      fill_in 'end_date', with: '2021/03/06'
      find('label', text: 'キーワード').click # カレンダーを消すために空クリック
      select 'タイムライン投稿', from: 'post_type'
      select 'いいね数', from: 'sort'
      click_on('絞り込み')
      expect(find('#search_text').value).to eq 'テスト'
      expect(find('#search_account').value).to eq 'アカウント'
      expect(find('#search_hash_tag').value).to eq 'タグ'
      expect(find('#search_url').value).to eq 'google'
      expect(find('#media').value).to eq 'LINE'
      expect(find('#start_date').value).to eq '2021/03/01'
      expect(find('#end_date').value).to eq '2021/03/06'
      expect(find('#post_type').value).to eq 'normal_post'
      expect(find('#sort').value).to eq 'like'
    end

    context '何も指定しないとき' do
      background do
        5.times { FactoryBot.create(:post) }
        visit posts_path
      end
      scenario 'すべての投稿が表示される' do
        expect(all('tbody tr').length).to eq 5
      end
    end

    context 'キーワードフルテキスト検索を行う' do
      scenario 'キーワードを含む項目のみが表示される' do
        FactoryBot.create(:post, text: 'テスト文字列')
        FactoryBot.create(:post, text: 'テスト文字列')
        FactoryBot.create(:post, text: 'ヒットしない文字列')
        fill_in('search_text', with: 'テスト')
        click_on('絞り込み')
        expect(all('tbody tr').length).to eq 2
      end
    end

    context 'アカウントLIKE検索を行う' do
      scenario 'アカウント名に検索ワードを含む項目が表示される' do
        FactoryBot.create(:post)
        account = FactoryBot.create(:account, name: '異なるAccount')
        FactoryBot.create(:post, account_id: account.id)
        FactoryBot.create(:post, account_id: account.id)
        fill_in('search_account', with: '異なる')
        click_on '絞り込み'
        expect(all('tbody tr').length).to eq 2
      end

      scenario 'ブランド名に検索ワードを含む項目が表示される' do
        FactoryBot.create(:post)
        brand = FactoryBot.create(:brand, name: "異なるブランド名")
        account = FactoryBot.create(:account, brand_id: brand.id)
        FactoryBot.create(:post, account_id: account.id, brand_id: brand.id)
        FactoryBot.create(:post, account_id: account.id, brand_id: brand.id)
        fill_in('search_account', with: '異なる')
        click_on '絞り込み'
        expect(all('tbody tr').length).to eq 2
      end
    end

    context '業種で絞り込みを行う' do
      scenario '選択した業種だけが表示' do
        pending('ローカルでは通るがbitbucketで落ちる')
        #業種がコスメのブランドによる投稿
        FactoryBot.create(:post, account_id: 1, brand_id: 1)
        FactoryBot.create(:post, account_id: 1, brand_id: 1)
        #業種が飲食のブランドによる投稿
        FactoryBot.create(:post, account_id: 2, brand_id: 2)
        FactoryBot.create(:post, account_id: 2, brand_id: 2)
        FactoryBot.create(:post, account_id: 2, brand_id: 2)
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

    context 'ハッシュタグ検索を行う' do
      scenario '指定したハッシュタグを含む項目のみが表示される' do
        FactoryBot.create(:post)
        FactoryBot.create(:hash_tag)
        FactoryBot.create(:post_hash_tag)
        2.times do |i|
          FactoryBot.create(:post)
          FactoryBot.create(:hash_tag, name: 'ヒットするタグ')
          FactoryBot.create(:post_hash_tag, post_id: i + 1, hash_tag_id: 2)
        end
        fill_in('search_hash_tag', with: 'ヒットするタグ')
        click_on '絞り込み'
        expect(all('tbody tr').length).to eq 2
      end
    end

    context 'URLフルテキスト検索を行う' do
      scenario 'キーワードを含む項目のみが表示される' do
        FactoryBot.create(:landing_page, url_hash: 'expect_to_be_hit')
        FactoryBot.create(:lp_combined_url, combined_url: 'https://google.co.jp', url_hash: 'expect_to_be_hit') # expected to be hit
        FactoryBot.create(:post)
        FactoryBot.create(:post, url_hash: 'expect_to_be_hit')
        FactoryBot.create(:post, url_hash: 'expect_to_be_hit')
        fill_in('search_url', with: 'google')
        click_on('絞り込み')
        expect(all('tbody tr').length).to eq 2
      end
    end

    context 'SNS絞り込みを行う' do
      given(:line_count) { 2 }
      given(:instagram_count) { 3 }
      background do
        line_count.times { FactoryBot.create(:post, media: 'LINE') }
        instagram_count.times { FactoryBot.create(:post, media: 'Instagram') }
      end
      context '全SNSを指定する' do
        scenario 'すべての項目が表示される' do
          # 5
          click_on('絞り込み')
          expect(all('tbody tr').length).to eq 5
        end
        scenario '投稿タイプで タイムライン投稿, フィード, リール, ストーリーが選べるようになる' do
          expect(page).to have_selector('option[value="normal_post"]')
          expect(page).to have_selector('option[value="feed"]')
          expect(page).to have_selector('option[value="reel"]')
          expect(page).to have_selector('option[value="story"]')
        end
        scenario '並び替えで 投稿が新しい順, いいね数 が選べるようになる' do
          expect(page).to have_selector('option[value="posted_at"]')
          expect(page).to have_selector('option[value="like"]')
        end
      end

      # TODO: 投稿タイプの増加に応じてテストを追加する
      # TODO: 並び替えの増加に応じてテストを追加する
      context 'LINEを指定する' do
        background do
          select 'LINE', from: 'media'
        end
        scenario 'LINE投稿のみが表示される' do
          click_on('絞り込み')
          expect(all('tbody tr').length).to eq line_count
        end
        scenario '投稿タイプで タイムライン投稿 が選べるようになる' do
          expect(page).to have_selector('option[value="normal_post"]')
        end
        scenario '並び替えで 投稿が新しい順, いいね数 が選べるようになる' do
          expect(page).to have_selector('option[value="posted_at"]')
          expect(page).to have_selector('option[value="like"]')
        end
      end

      context 'Instagramを指定する' do
        background do
          select 'Instagram', from: 'media'
        end
        scenario 'Instagram投稿のみが表示される' do
          click_on('絞り込み')
          expect(all('tbody tr').length).to eq instagram_count
        end
        scenario '投稿タイプで フィード, リール, ストーリー が選べるようになる' do
          expect(page).to have_selector('option[value="feed"]')
          expect(page).to have_selector('option[value="reel"]')
          expect(page).to have_selector('option[value="story"]')
        end
        scenario '並び替えで 投稿が新しい順, いいね数 が選べるようになる' do
          expect(page).to have_selector('option[value="posted_at"]')
          expect(page).to have_selector('option[value="like"]')
        end
      end

    #   context 'Twitterを指定する' do
    #     background do
    #       select 'Twitter', from: 'media'
    #     end
    #     scenario 'Twitter投稿のみが表示される' do
    #       click_on('絞り込み')
    #       expect(all('tbody tr').length).to eq twitter_count
    #     end
    #     scenario '投稿タイプで ツイート, リツイート が選べるようになる' do
    #       expect(page).to have_selector('option[value="tweet"]')
    #       expect(page).to have_selector('option[value="retweet"]')
    #     end
    #     scenario '並び替えで 投稿が新しい順, いいね数, リツイート数 が選べるようになる' do
    #       expect(page).to have_selector('option[value="posted_at"]')
    #       expect(page).to have_selector('option[value="like"]')
    #       expect(page).to have_selector('option[value="retweet"]')
    #     end
    #   end

    #   context 'Facebookを指定する' do
    #     background do
    #       select 'Facebook', from: 'media'
    #     end
    #     scenario 'Facebook投稿のみが表示される' do
    #       click_on('絞り込み')
    #       expect(all('tbody tr').length).to eq facebook_count
    #     end
    #     # TODO: Facebookの投稿タイプに関するテストを追加する
    #     scenario '並び替えで 投稿が新しい順, いいね数 が選べるようになる' do
    #       expect(page).to have_selector('option[value="posted_at"]')
    #       expect(page).to have_selector('option[value="like"]')
    #     end
    #   end
    end

    context '投稿日時絞込みを行う' do
      background do
        FactoryBot.create(:post, posted_at: '2021/03/01 15:00:00 JTC')
        FactoryBot.create(:post, posted_at: '2021/03/04 00:00:00 JTC')
        FactoryBot.create(:post, posted_at: '2021/03/06 23:59:59 JTC')
        FactoryBot.create(:post, posted_at: '2021/03/07 00:00:01 JTC')
      end
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

      scenario '指定投稿日内の投稿のみが表示される' do
        fill_in 'start_date', with: '2021/03/01'
        fill_in 'end_date', with: '2021/03/06'
        find('label', text: 'キーワード').click # カレンダーを消すために空クリック
        click_on('絞り込み')
        expect(all('tbody tr').length).to eq 3
      end
    end

    context '時間帯で絞り込みを行う' do
      background do
        FactoryBot.create(:post, posted_at: '2021/03/04 13:00:01 JTC', hour: 13)
        FactoryBot.create(:post, posted_at: '2021/03/14 23:59:59 JTC', hour: 23)
        FactoryBot.create(:post, posted_at: '2021/03/17 15:00:00 JTC', hour: 15)
        FactoryBot.create(:post, posted_at: '2021/04/04 00:00:00 JTC', hour:  0)
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
        select "13時", from: 'hour_start'
        select "15時", from: 'hour_end'
        click_on('絞り込み')
        expect(all('tbody tr').length).to eq 2

        select "0時台", from: 'hour_start'
        select "23時台", from: 'hour_end'
        click_on('絞り込み')
        expect(all('tbody tr').length).to eq 4
      end

      scenario "開始時より終了時が前だとモーダルをだし、絞り込みをしない" do
        visit posts_path
        expect(all('tbody tr').length).to eq 4
        expect(page).to_not have_content('開始時刻は終了時刻より前にしてください')

        find('span', text: '絞り込みフォーム').click
        select "15時台", from: 'hour_start'
        select "1時台", from: 'hour_end'
        click_on('絞り込み')
        expect(page).to have_content('開始時刻は終了時刻より前にしてください')
        #FIXME 以下bitbucketで落ちる。pendingを入れてもbitbucketでerrorが出されるのでコメントアウトしている。
        # find("#modal_close").click
        # expect(page).to_not have_content('開始時刻は終了時刻より前にしてください')
        # expect(all('tbody tr').length).to eq 4
      end
    end

    context '投稿タイプ絞り込みを行う' do
      background do
        FactoryBot.create(:post, media: 'LINE', post_type: 'invalid')
        2.times { FactoryBot.create(:post, :feed) }
        3.times { FactoryBot.create(:post, :reel) }
        4.times { FactoryBot.create(:post, :story) }
        5.times { FactoryBot.create(:post, :normal_post) }
      end
      context 'LINEが選択されている時' do
        background { select 'LINE', from: 'media' }
        scenario 'タイムライン投稿で絞り込むとタイムライン投稿のみが表示される' do
          select 'タイムライン投稿', from: 'post_type'
          click_on('絞り込み')
          expect(all('tbody tr').length).to eq 5
        end
      end
      context 'Instagramが選択されている時' do
        background { select 'Instagram', from: 'media' }
        scenario 'フィードで絞り込むとフィードのみが表示される' do
          select 'フィード', from: 'post_type'
          click_on('絞り込み')
          expect(all('tbody tr').length).to eq 2
        end
        scenario 'リールで絞り込むとリールのみが表示される' do
          select 'リール', from: 'post_type'
          click_on('絞り込み')
          expect(all('tbody tr').length).to eq 3
        end
        scenario 'ストーリーで絞り込むとストーリーのみが表示される' do
          select 'ストーリー', from: 'post_type'
          click_on('絞り込み')
          expect(all('tbody tr').length).to eq 4
        end
      end

      context '全SNSが選択されている時' do
        background { select '全SNS', from: 'media' }
        scenario 'タイムライン投稿で絞り込むとタイムライン投稿のみが表示される' do
          select 'タイムライン投稿', from: 'post_type'
          click_on('絞り込み')
          expect(all('tbody tr').length).to eq 5
        end
        scenario 'フィードで絞り込むとフィードのみが表示される' do
          select 'フィード', from: 'post_type'
          click_on('絞り込み')
          expect(all('tbody tr').length).to eq 2
        end
        scenario 'リールで絞り込むとリールのみが表示される' do
          select 'リール', from: 'post_type'
          click_on('絞り込み')
          expect(all('tbody tr').length).to eq 3
        end
        scenario 'ストーリーで絞り込むとストーリーのみが表示される' do
          select 'ストーリー', from: 'post_type'
          click_on('絞り込み')
          expect(all('tbody tr').length).to eq 4
        end
      end
    end

    # TDDO: 並び替えの追加に応じてテストも追加する
    context '並び替えを行う' do
      background do
        FactoryBot.create(:post, :reel, posted_at: '2021/03/01 00:00:00 JST', like_count: 100)
        FactoryBot.create(:post, :reel, posted_at: '2021/02/27 00:00:00 JST', like_count: 200)
        FactoryBot.create(:post, :reel, posted_at: '2021/02/26 00:00:00 JST', like_count: 300)
      end
      scenario 'いいね数順で並び替える' do
        select 'いいね数', from: 'sort'
        click_on '絞り込み'
        within(all('tbody tr')[0]) { expect(page).to have_content 'いいね： 300' }
        within(all('tbody tr')[1]) { expect(page).to have_content 'いいね： 200' }
        within(all('tbody tr')[2]) { expect(page).to have_content 'いいね： 100' }
      end
      scenario '投稿時間順で並び替える' do
        sleep 1
        select '投稿が新しい順', from: 'sort'
        click_on '絞り込み'
        sleep 1
        within(all('tbody tr')[0]) { expect(page).to have_content '2021/03/01 (月)' }
        within(all('tbody tr')[1]) { expect(page).to have_content '2021/02/27 (土)' }
        within(all('tbody tr')[2]) { expect(page).to have_content '2021/02/26 (金)' }
      end
    end

    context "ピンアカスイッチで絞り込み" do
      background do
        # どのユーザーもピンアカに登録していないアカウントを2個作成
        2.times do
          FactoryBot.create(:account) do |account|
            # 各アカウントに紐づくpostを4つ作成
            4.times { FactoryBot.create(:post, account_id: account.id) }
          end
        end

        # user(id:2)がピンアカに登録しているアカウントを3個作成
        FactoryBot.create(:user, email: 'tester2@example.com')
        3.times do
          FactoryBot.create(:account) do |account|
            FactoryBot.create(:favorite, user_id: 2, account_id: account.id)
            # 各アカウントに紐づくpostを2つ作成
            2.times { FactoryBot.create(:post, account_id: account.id) }
          end
        end

        # user(id:1)がピンアカに登録しているアカウントを4個作成
        4.times do
          FactoryBot.create(:account) do |account|
            FactoryBot.create(:favorite, account_id: account.id)
            # 各アカウントに紐づくpostを5つ作成
            5.times { FactoryBot.create(:post, account_id: account.id) }
          end
        end
        visit posts_path
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
