require 'rails_helper'

feature "LP詳細画面" do

  background do
    FactoryBot.create(:company)
    FactoryBot.create(:market)
    FactoryBot.create(:brand)
    @account1 = FactoryBot.create(:account)      # id: 1, name: アカウント1
    lp = FactoryBot.create(:landing_page)
    FactoryBot.create(:post, url_hash: lp.url_hash)   # id: 1
    FactoryBot.create(:post, url_hash: lp.url_hash, text: "second_post")   # id: 2
    lp2 = FactoryBot.create(:landing_page, :landing_page2)
    FactoryBot.create(:post, url_hash: lp2.url_hash, text: "redirect_to_another_lp")    # id: 3

    @user = FactoryBot.create(:user)

    visit root_path
    fill_in "user_email", with: "tester@example.com"
    fill_in "user_password", with: "000000"
    click_on "ログイン"
  end

  context '遷移' do
    scenario 'LP検索画面からLP詳細画面へ正しく遷移できる' do
      find('.fa-newspaper').click
      find('.sidenav-normal', text: "LP検索").click
      first('tbody tr').click
      within_window(windows.last) do
        expect(current_path).to eq landing_page_path(id: 1)
      end
    end
  end

  context 'パンくずリスト' do
    scenario 'LP検索をクリックするとLP検索画面に遷移' do
      visit landing_page_path(id: 1)
      find('.breadcrumb-item', text: "LP検索").click
      expect(current_path).to eq landing_pages_path
    end

    scenario 'LP詳細が表示されている' do
      visit landing_page_path(id: 1)
      expect(find('.breadcrumb-item > .disable_a')).to have_content("LP詳細")
    end
  end

  context '画面の表示' do
    scenario 'タイトル、ディスクリプション、リンク元投稿数、URLが表示されている' do
      visit landing_page_path(id: 1)
      dds = all('dd')
      expect(dds[0]).to have_content "background_lp"
      expect(dds[1]).to have_content "新生活が始まる季節にぴったりな、フルーティーなバナナの甘さと、アーモンドミルクのほのかな香ばしさを楽しめるフラペチーノ® が登場。新しいスタイルで楽しむフードの開発ストーリーや、新生活をいろどるカラフルなグッズの情報を先行してご紹介します。"
      expect(dds[2]).to have_content "2"
      expect(dds[3]).to have_content "http://landing/page/url"
    end

    scenario '遷移先がLPの投稿一覧が表示されている' do
      visit landing_page_path(id: 1)
      expect(find('#lp_posts_table > tbody').all('tr').length).to eq 2
      expect(page).to have_content("text")
      expect(page).to_not have_content("redirect_to_another_lp")
    end
  end

  feature '絞り込みフォーム機能' do
    context 'キーワードフルテキスト検索を行う' do
      scenario 'キーワードを含むPostのみが表示される' do
        lp = LandingPage.find(1)
        FactoryBot.create(:post, text: 'テスト文字列', url_hash: lp.url_hash)
        FactoryBot.create(:post, text: 'テスト文字列', url_hash: lp.url_hash)
        FactoryBot.create(:post, text: 'ヒットしない文字列', url_hash: lp.url_hash)

        visit landing_page_path(id: 1)
        expect(find('#lp_posts_table > tbody').all('tr').length).to eq 5
        find('span', text: "絞り込みフォーム").click

        fill_in('search_text', with: 'テスト')
        click_on('絞り込み')
        expect(find('#lp_posts_table > tbody').all('tr').length).to eq 2
      end
    end

    context 'ハッシュタグ検索を行う' do
      scenario '指定したハッシュタグを含むPostのみが表示される' do
        FactoryBot.create(:hash_tag)
        FactoryBot.create(:post_hash_tag)
        FactoryBot.create(:hash_tag, name: 'ヒットするタグ')
        FactoryBot.create(:post_hash_tag, post_id: 2, hash_tag_id: 2)

        visit landing_page_path(id: 1)
        expect(find('#lp_posts_table > tbody').all('tr').length).to eq 2
        find('span', text: "絞り込みフォーム").click

        fill_in('search_hash_tag', with: 'ヒットするタグ')
        click_on '絞り込み'
        expect(find('#lp_posts_table > tbody').all('tr').length).to eq 1
        expect(page).to have_content("second_post")
      end
    end

    context 'SNS絞り込みを行う' do
      background do
        lp = LandingPage.find(1)
        FactoryBot.create(:post, media: 'LINE', text: "post_in_line", url_hash: lp.url_hash)
        visit landing_page_path(id: 1)
        find('span', text: "絞り込みフォーム").click
      end

      scenario '全SNSを指定する' do
        expect(find('#lp_posts_table > tbody').all('tr').length).to eq 3
        select '全SNS', from: 'SNS'
        click_on '絞り込み'

        expect(find('#lp_posts_table > tbody').all('tr').length).to eq 3
      end

      scenario 'LINEを指定する' do
        expect(find('#lp_posts_table > tbody').all('tr').length).to eq 3
        select 'LINE', from: 'SNS'
        click_on '絞り込み'

        #最初につくった2つが選ばれる
        expect(find('#lp_posts_table > tbody').all('tr').length).to eq 1
        expect(find('#lp_posts_table > tbody')).to have_content('post_in_line')
      end

      scenario 'Instagramを指定する' do
        expect(find('#lp_posts_table > tbody').all('tr').length).to eq 3
        select 'Instagram', from: 'SNS'
        click_on '絞り込み'

        expect(find('#lp_posts_table > tbody').all('tr').length).to eq 2
        expect(find('#lp_posts_table > tbody')).to have_content('text')
        expect(find('#lp_posts_table > tbody')).to have_content('second_post')
      end

    end

    context '投稿日時絞込みを行う' do
      background do
        lp = LandingPage.find(1)
        FactoryBot.create(:post, posted_at: '2021/03/01 15:00:00 JTC', url_hash: lp.url_hash)
        FactoryBot.create(:post, posted_at: '2021/03/04 00:00:00 JTC', url_hash: lp.url_hash)
        FactoryBot.create(:post, posted_at: '2021/03/06 23:59:59 JTC', url_hash: lp.url_hash)
        FactoryBot.create(:post, posted_at: '2021/03/07 00:00:01 JTC', url_hash: lp.url_hash)
        visit landing_page_path(id: 1)
        find('span', text: "絞り込みフォーム").click
      end

      scenario '指定投稿日内の投稿のみが表示される' do
        expect(find('#lp_posts_table > tbody').all('tr').length).to eq 6
        fill_in 'start_date', with: '2021/03/01'
        fill_in 'end_date', with: '2021/03/06'
        find('label', text: "キーワード").click #カレンダーを消すために空クリック
        click_on('絞り込み')

        expect(find('#lp_posts_table > tbody').all('tr').length).to eq 3
      end
    end
  end
  # TODO: 並び替えが実装され次第FeatureSpecを追加する
  # TODO: 投稿タイプ絞り込みが実装され次第FeatureSpecを追加する
end
