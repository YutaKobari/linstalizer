require 'rails_helper'

feature "LP検索画面テスト" do

  background do
    FactoryBot.create(:company)
    FactoryBot.create(:market)
    FactoryBot.create(:brand)
    @account1 = FactoryBot.create(:account)      # id: 1, name: アカウント1
    lp = FactoryBot.create(:landing_page)
    FactoryBot.create(:post, url_hash: lp.url_hash)

    FactoryBot.create(:market, name: "飲食") #id = 2
    FactoryBot.create(:brand, name: "飲食のブランド", market_id: 2)
    FactoryBot.create(:account, brand_id: 2) #id = 2

    @user = FactoryBot.create(:user)

    visit root_path
    fill_in "user_email", with: "tester@example.com"
    fill_in "user_password", with: "000000"
    click_on "ログイン"
  end

  scenario "条件を何も指定しないと全てのレコードが返ってくる" do
    9.times {
      lp = FactoryBot.create(:landing_page)
      FactoryBot.create(:post, url_hash: lp.url_hash)
    } # id: 2 〜 10
    expect(LandingPage.all.size).to eq 10
    visit(landing_pages_path)
    expect(all(:css, 'tbody > tr').size).to eq(10)
  end

  context "キーワードで検索する" do
    background do
      FactoryBot.create(:landing_page, title: "first_lp") do |landing_page| # id: 2
        FactoryBot.create(:post, url_hash: landing_page.url_hash)
        FactoryBot.create(:lp_search_ngram, url_hash: landing_page.url_hash)
      end
      FactoryBot.create(:landing_page, title: "second_lp") do |landing_page| # id: 3
        FactoryBot.create(:post, url_hash: landing_page.url_hash)
        FactoryBot.create(:lp_search_ngram2, url_hash: landing_page.url_hash)
      end
      visit(landing_pages_path)
    end

    scenario "フルテキスト検索" do
      expect(all(:css, 'tbody > tr').size).to eq(3)
      find('span', text: "絞り込みフォーム").click
      fill_in 'search_text', with: "キーワード"
      click_on "絞り込み"
      expect(all(:css, 'tbody > tr').size).to eq(1)
      expect(all(:css, 'tbody > tr')[0]).to have_content 'first_lp'
    end
  end

  context "URLで検索" do
    background do
      FactoryBot.create(:landing_page, title: "first_lp") do |landing_page| # id: 2
        FactoryBot.create(:post, url_hash: landing_page.url_hash)
        FactoryBot.create(:lp_combined_url, url_hash: landing_page.url_hash)
      end
      FactoryBot.create(:landing_page, title: "second_lp") do |landing_page| # id: 3
        FactoryBot.create(:post, url_hash: landing_page.url_hash)
        FactoryBot.create(:lp_combined_url, :lp_combined_url2, url_hash: landing_page.url_hash)
      end
      visit(landing_pages_path)
    end

    scenario "検索ワードをurlに含むLPが表示される" do
      expect(all(:css, 'tbody > tr').size).to eq(3)
      find('span', text: "絞り込みフォーム").click
      fill_in 'search_url', with: "example.com"
      click_on "絞り込み"
      expect(all(:css, 'tbody > tr').size).to eq(1)
      expect(all(:css, 'tbody > tr')[0]).to have_content 'first_lp'
    end
  end

  context "業種で絞り込み" do
    scenario '選択した業種だけが表示' do
      FactoryBot.create(:landing_page, title: "first_lp") do |landing_page| # id: 2
        FactoryBot.create(:post, url_hash: landing_page.url_hash)
        FactoryBot.create(:lp_combined_url, url_hash: landing_page.url_hash)
      end
      FactoryBot.create(:landing_page, title: "3_lp", brand_id: 2) do |landing_page| # id: 3
        FactoryBot.create(:post, url_hash: landing_page.url_hash)
        FactoryBot.create(:lp_combined_url, url_hash: landing_page.url_hash)
      end
      FactoryBot.create(:landing_page, title: "4_lp", brand_id: 2) do |landing_page| # id: 4
        FactoryBot.create(:post, url_hash: landing_page.url_hash)
        FactoryBot.create(:lp_combined_url, url_hash: landing_page.url_hash)
      end
      FactoryBot.create(:landing_page, title: "5_lp", brand_id: 2) do |landing_page| # id: 5
        FactoryBot.create(:post, url_hash: landing_page.url_hash)
        FactoryBot.create(:lp_combined_url, url_hash: landing_page.url_hash)
      end
      visit(landing_pages_path)
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

  context "並べ替え" do
    background do
      FactoryBot.create(:landing_page, title: "first_lp", max_published_at: "2021/02/01") do |landing_page| # id: 2
        FactoryBot.create(:post, url_hash: landing_page.url_hash)
        FactoryBot.create(:post, url_hash: landing_page.url_hash, posted_at: "2021/02/14".to_datetime)
        FactoryBot.create(:post, url_hash: landing_page.url_hash, posted_at: "2021/02/15".to_datetime)
        FactoryBot.create(:lp_combined_url, url_hash: landing_page.url_hash)
      end
      FactoryBot.create(:landing_page, title: "second_lp", max_published_at: "2021/02/03") do |landing_page| # id: 3
        FactoryBot.create(:post, url_hash: landing_page.url_hash)
        FactoryBot.create(:post, url_hash: landing_page.url_hash)
        FactoryBot.create(:post, url_hash: landing_page.url_hash, posted_at: "2021/02/02".to_datetime)
        FactoryBot.create(:post, url_hash: landing_page.url_hash, posted_at: "2021/02/03".to_datetime)
        FactoryBot.create(:post, url_hash: landing_page.url_hash, posted_at: "2021/02/04".to_datetime)
        FactoryBot.create(:lp_combined_url, :lp_combined_url2, url_hash: landing_page.url_hash)
      end
      FactoryBot.create(:landing_page, title: "third_lp", max_published_at: "2021/02/02") do |landing_page| # id: 4
        FactoryBot.create(:post, url_hash: landing_page.url_hash)
        FactoryBot.create(:post, url_hash: landing_page.url_hash)
        FactoryBot.create(:post, url_hash: landing_page.url_hash, posted_at: "2021/03/02".to_datetime )
        FactoryBot.create(:post, url_hash: landing_page.url_hash, posted_at: "2021/03/02".to_datetime )
        FactoryBot.create(:lp_combined_url, :lp_combined_url2, url_hash: landing_page.url_hash)
      end
      visit(landing_pages_path)
    end

    scenario "デフォルトはリンク元投稿数順" do
      expect(all(:css, 'tbody > tr').size).to eq(4)
      expect(find(:css, 'tr:nth-child(1) > td:nth-child(3)')).to have_content('second_lp')
      expect(find(:css, 'tr:nth-child(2) > td:nth-child(3)')).to have_content('third_lp')
      expect(find(:css, 'tr:nth-child(3) > td:nth-child(3)')).to have_content('first_lp')
      expect(find(:css, 'tr:nth-child(4) > td:nth-child(3)')).to have_content('background_lp')
    end
    scenario "最新出稿日順で並べ替え" do
      expect(all(:css, 'tbody > tr').size).to eq(4)
      find('span', text: "絞り込みフォーム").click
      select '最新出稿日順', from: '並べ替え'
      click_on "絞り込み"
      expect(find(:css, 'tr:nth-child(1) > td:nth-child(3)')).to have_content('background_lp')
      expect(find(:css, 'tr:nth-child(2) > td:nth-child(3)')).to have_content('second_lp')
      expect(find(:css, 'tr:nth-child(3) > td:nth-child(3)')).to have_content('third_lp')
      expect(find(:css, 'tr:nth-child(4) > td:nth-child(3)')).to have_content('first_lp')

      select 'リンク元投稿数順', from: '並べ替え'
      click_on "絞り込み"
      expect(find(:css, 'tr:nth-child(1) > td:nth-child(3)')).to have_content('second_lp')
      expect(find(:css, 'tr:nth-child(2) > td:nth-child(3)')).to have_content('third_lp')
      expect(find(:css, 'tr:nth-child(3) > td:nth-child(3)')).to have_content('first_lp')
      expect(find(:css, 'tr:nth-child(4) > td:nth-child(3)')).to have_content('background_lp')
    end
  end

  context "ピンアカスイッチで絞り込み" do
    background do
      # どのユーザーもピンアカに登録していないアカウントを2個作成。LPはブランドと紐づくため、ブランドから作成。
      2.times do
        FactoryBot.create(:brand) do |brand|
          FactoryBot.create(:account, brand_id: brand.id)
          # ブランドに紐づくlpを4つ作成
          4.times do
            lp = FactoryBot.create(:landing_page, brand_id: brand.id)
            FactoryBot.create(:post, url_hash: lp.url_hash)
          end
        end
      end

      # user(id:2)がピンアカに登録しているアカウントを3個作成
      FactoryBot.create(:user, email: 'tester2@example.com')
      3.times do
        FactoryBot.create(:brand) do |brand|
          account = FactoryBot.create(:account, brand_id: brand.id)
          FactoryBot.create(:favorite, user_id: 2, account_id: account.id)
          # ブランドに紐づくlpを2つ作成
          2.times do
            lp = FactoryBot.create(:landing_page, brand_id: brand.id)
            FactoryBot.create(:post, url_hash: lp.url_hash)
          end
        end
      end

      # user(id:1)がピンアカに登録しているアカウントと、同ブランドの登録していないアカウントをそれぞれ4つ作成
      # 同ブランド内にピンアカ登録しているアカウントが一つでもあったら、そのブランドに紐づくLPは全て表示されるかをテストするため未登録アカウントを作成している
      4.times do
        FactoryBot.create(:brand) do |brand|
          account1 = FactoryBot.create(:account, brand_id: brand.id) # ピンアカ登録
          FactoryBot.create(:favorite, account_id: account1.id)
          account2 = FactoryBot.create(:account, media: 'LINE', brand_id: brand.id) # ピンアカ未登録
          # ブランドに紐づくlpを5つ作成
          5.times do
            lp = FactoryBot.create(:landing_page, brand_id: brand.id)
            FactoryBot.create(:post, url_hash: lp.url_hash)
          end
        end
      end
      visit landing_pages_path
      expect(all('tbody > tr').size).to eq(35) # 1(最初のbackground) + 2×4 + 3×2 + 4×5 = 34
    end

    scenario "ピンアカスイッチONでピンアカのみ表示、OFFで解除" do
      find('span', text: "絞り込みフォーム").click
      find('label', text: "Off").click
      click_on '絞り込み'
      expect(all('tbody > tr').size).to eq(20)
      find('label', text: "On").click
      click_on '絞り込み'
      expect(all('tbody > tr').size).to eq(35)
    end
  end
end
