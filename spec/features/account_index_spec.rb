require 'rails_helper'

feature "アカウント検索画面" do
   given(:email)    { 'tester@example.com' }
   given(:password) { '000000' }

  background do
    FactoryBot.create(:user)
    FactoryBot.create(:company)
    FactoryBot.create(:market)
    FactoryBot.create(:brand)
    @account1 = FactoryBot.create(:account)      # id: 1, name: アカウント1
    FactoryBot.create(:daily_account_engagement) # account_id: 1
    FactoryBot.create(:market, name: "飲食") #id = 2
    FactoryBot.create(:brand, name: "飲食のブランド", market_id: 2)
    visit root_path
    fill_in "user_email",    with: email
    fill_in "user_password", with: password
    click_on "ログイン"
  end

  scenario "titleタグがパンくずのテキストになっている" do
    click_on "アカウント検索"
    find('.sidenav-normal', text: '全SNS').click
    expect(page).to have_title 'アカウント検索 | 全SNS | SNSクロール'
  end

  context 'パンくずリスト' do
    scenario '全SNSで検索' do
      click_on "アカウント検索"
      find('.sidenav-normal', text: '全SNS').click
      expect(page).to have_selector(".breadcrumb-item", text: '全SNS')
    end

    scenario 'LINEで検索' do
      click_on "アカウント検索"
      find('.sidenav-normal', text: 'LINE').click
      expect(page).to have_selector(".breadcrumb-item", text: 'LINE')
    end

    scenario 'Instagramで検索' do
      click_on "アカウント検索"
      find('.sidenav-normal', text: 'Instagram').click
      expect(page).to have_selector(".breadcrumb-item", text: 'Instagram')
    end

  end

  scenario "条件を何も指定しないと全てのレコードが返ってくる" do
    9.times { FactoryBot.create(:account) } # id: 2 〜 10
    9.times { FactoryBot.create(:daily_account_engagement, :nth_daily_account_engagement) } # account_id: 2 〜 10
    expect(Account.all.size).to eq 10
    click_on "アカウント検索"
    find('.sidenav-normal', text: '全SNS').click
    expect(all(:css, 'tbody > tr').size).to eq(10)
  end

  context "アカウント名で検索する" do
    background do
      FactoryBot.create(:company, name: "target_company") do |company|
        FactoryBot.create(:brand, company_id: company.id,  name: "target_brand") # id: 3
        FactoryBot.create(:brand, company_id: company.id,  name: "hoge")         # id: 4
      end
      account2 = FactoryBot.create(:account, name: "アカウント2", brand_id: 3) # id: 2
      account3 = FactoryBot.create(:account, name: "アカウント3", brand_id: 4) # id: 3
      FactoryBot.create(:daily_account_engagement, account_id: account2.id)
      FactoryBot.create(:daily_account_engagement, date: '2021/2/04'.to_date, account_id: account2.id, follower: 0)
      FactoryBot.create(:daily_account_engagement, account_id: account3.id, follower: 999)
      FactoryBot.create(:daily_account_engagement, date: '2021/2/04'.to_date, account_id: account3.id, follower: 0)
      click_on "アカウント検索"
      find('.sidenav-normal', text: '全SNS').click
    end
    scenario "nameに検索ワードがマッチするアカウントが表示される" do
      expect(all(:css, 'tbody > tr').size).to eq(3)
      find('span', text: "絞り込みフォーム").click
      fill_in 'search_account', with: "ウント1"
      click_on "絞り込み"
      expect(all(:css, 'tbody > tr').size).to eq(1)
      expect(all(:css, 'tbody > tr')[0]).to have_content 'アカウント1'
    end
    scenario "検索ワードにマッチするブランドに紐づくアカウントが表示される" do
      expect(all(:css, 'tbody > tr').size).to eq(3)
      find('span', text: "絞り込みフォーム").click
      fill_in 'search_account', with: "rget_bra"
      click_on "絞り込み"
      expect(all(:css, 'tbody > tr').size).to eq(1)
      expect(all(:css, 'tbody > tr')[0]).to have_content 'アカウント2'
    end
    scenario "検索ワードにマッチする企業に紐づくアカウントが表示される" do
      expect(all(:css, 'tbody > tr').size).to eq(3)
      find('span', text: "絞り込みフォーム").click
      fill_in 'search_account', with: "arget_com"
      click_on "絞り込み"
      expect(all(:css, 'tbody > tr').size).to eq(2)
      expect(all(:css, 'tbody > tr')[0]).to have_content 'アカウント2'
      expect(all(:css, 'tbody > tr')[1]).to have_content 'アカウント3'
    end
  end

  context "業種で検索" do
    scenario '選択した業種だけが表示' do
      pending('ローカルでは通るがCIで落ちる')
      FactoryBot.create(:account) # id: 2

      FactoryBot.create(:account, brand_id: 2) #id = 3
      FactoryBot.create(:account, brand_id: 2) #id = 4
      FactoryBot.create(:account, brand_id: 2) #id = 5

      visit accounts_path
      expect(all('tbody tr').length).to eq 5

      find('span', text: '絞り込みフォーム').click
      select 'コスメ・美容', from: '業種'
      click_on '絞り込み'
      expect(all('tbody tr').length).to eq 2
      within(:css, 'table') do
        expect(page).to_not have_content '飲食'
        expect(page).to have_content 'コスメ・美容'
      end

      select '飲食', from: '業種'
      click_on '絞り込み'
      expect(all('tbody tr').length).to eq 3
      within(:css, 'table') do
        expect(page).to have_content '飲食'
        expect(page).to_not have_content 'コスメ・美容'
      end

      select '全業種', from: '業種'
      click_on '絞り込み'
      expect(all('tbody tr').length).to eq 5
      within(:css, 'table') do
        expect(page).to have_content '飲食'
        expect(page).to have_content 'コスメ・美容'
      end
    end
  end

  context "SNSで検索" do
    background do
      FactoryBot.create(:account, media: "LINE", name: 'ラインアカウント') # id: 2
      FactoryBot.create(:daily_account_engagement, account_id: 2)
      FactoryBot.create(:account, media: "Instagram", name: 'インスタアカウント') # id: 3
      FactoryBot.create(:daily_account_engagement, account_id: 3)
    end

    scenario "SNSが一致するアカウントが表示される" do
      click_on "アカウント検索"
      find('.sidenav-normal', text: '全SNS').click
      expect(all(:css, 'tbody > tr').size).to eq(3)
      find('span', text: "絞り込みフォーム").click
      select 'LINE', from: "media"
      click_on "絞り込み"
      expect(all(:css, 'tbody > tr').size).to eq(1)
      expect(all(:css, 'tbody > tr')[0]).to have_content 'ラインアカウント'
    end

    scenario "サイドバーで予めSNSを指定することができる" do
      click_on "アカウント検索"
      find('.sidenav-normal', text: '全SNS').click
      expect(all(:css, 'tbody > tr').size).to eq(3)
      find('.fa-user-circle').click
      click_on "LINE"
      find('span', text: "絞り込みフォーム").click
      expect(page).to have_field 'SNS', with: 'LINE'
      expect(all(:css, 'tbody > tr').size).to eq(1)
      expect(all(:css, 'tbody > tr')[0]).to have_content 'ラインアカウント'
    end
  end

  context "集計期間を指定" do
    background do
      # account_id: 1, date: 2021/2/10, follower: 1000,  post_count: 50,  total_reaction: 3000
      # ↑最上部backgroundで定義
      # account_id: 1, date: 2021/2/11, follower: 1100,  post_count: 52,  total_reaction: 3200
      FactoryBot.create(:daily_account_engagement, account_id: 1, date: '2021/2/11'.to_date, follower: 1100, post_count: 52, total_reaction: 3500)
      # account_id: 1, date: 2021/2/12, follower: 1800,  post_count: 60,  total_reaction: 4000
      FactoryBot.create(:daily_account_engagement, account_id: 1, date: '2021/2/12'.to_date, follower: 1800, post_count: 60, total_reaction: 4000)
      # account_id: 1, date: 昨日,      follower: 10000, post_count: 300, total_reaction: 28000
      FactoryBot.create(:daily_account_engagement, account_id: 1, date: Date.today, follower: 10000, post_count: 300, total_reaction: 28000)
      FactoryBot.create(:daily_account_engagement, account_id: 1, date: Date.today - 6.days, follower: 9111, post_count: 233, total_reaction: 18000)
      click_on "アカウント検索"
      find('.sidenav-normal', text: '全SNS').click
    end

    scenario '全期間をクリックすると2020/01/01から今日の日付がセットされる' do
      find('span', text: "絞り込みフォーム").click
      find('#account_index_all_periods_aggregation').click
      expect(find('#aggregated_from').value).to eq '2000/01/01'
      expect(find('#aggregated_to').value).to eq I18n.l((Date.today).to_date)
    end

    scenario "1週間をクリックすると今日までの1週間の日付がセットされる" do
      find('span', text: "絞り込みフォーム").click
      find('#one_week_aggregation').click
      expect(find('#aggregated_from').value).to eq I18n.l((Date.today - 6.day).to_date)
      expect(find('#aggregated_to').value).to eq I18n.l((Date.today).to_date)
    end

    scenario "集計期間はデフォルトで1週間となる" do
      expect(all(:css, 'tbody > tr').size).to eq(1)
      find('span', text: "絞り込みフォーム").click
      click_on "絞り込み"
      expect(all(:css, 'tbody > tr').size).to eq(1)
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(6)', text: '67') #投稿数
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(7)', text: '10,000') #反応数
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(7)', text: '55.5556%') #反応数増加率
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(8)', text: '889') #フォロワー増加数
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(8)', text: '9.7574%') #フォロワー増加率
    end
    scenario "集計期間を全期間にすると今日のエンゲージメント値が返ってくる" do
      expect(all(:css, 'tbody > tr').size).to eq(1)
      find('span', text: "絞り込みフォーム").click
      find('#account_index_all_periods_aggregation').click
      click_on "絞り込み"
      expect(all(:css, 'tbody > tr').size).to eq(1)
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(6)', text: '300') #投稿数
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(7)', text: '28,000') #反応数
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(7)', text: '-') #反応数増加率
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(8)', text: '10,000') #フォロワー増加数
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(8)', text: '-') #フォロワー増加率
    end
    scenario "全期間指定後、集計終了日を指定すると指定日時点のエンゲージメント値が返ってくる" do
      expect(all(:css, 'tbody > tr').size).to eq(1)
      find('span', text: "絞り込みフォーム").click
      find('#account_index_all_periods_aggregation').click
      fill_in  "aggregated_to", with: '2021/02/12'
      find('label', text: "集計期間").click #カレンダーを消すために空クリック
      click_on "絞り込み"
      expect(all(:css, 'tbody > tr').size).to eq(1)
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(6)', text: '60') #投稿数
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(7)', text: '4,000') #反応数
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(7)', text: '-') #反応数増加率
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(8)', text: '1,800') #フォロワー増加数
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(8)', text: '-') #フォロワー増加率
    end
    scenario "集計開始日のみ指定すると指定日と最新取得日（今日or昨日）の差が返ってくる" do
      expect(all(:css, 'tbody > tr').size).to eq(1)
      find('span', text: "絞り込みフォーム").click
      fill_in "aggregated_from", with: '2021/02/11'
      click_on "絞り込み"
      expect(all(:css, 'tbody > tr').size).to eq(1)
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(6)', text: '248')       # 300 - 52 #投稿数
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(7)', text: '24,500')    # 28000 - 3500 #反応数
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(7)', text: '700.0%')      # 24500 / 3500 * 100 #反応数増加率
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(8)', text: '8,900')     # 10000 - 1100 #フォロワー増加数
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(8)', text: '809.0909%') # 8900 / 1100 * 100  #フォロワー増加率
    end
    scenario "集計期間を指定すると開始日と終了日の差が返ってくる" do
      expect(all(:css, 'tbody > tr').size).to eq(1)
      find('span', text: "絞り込みフォーム").click
      fill_in "aggregated_from", with: '2021/02/10'
      fill_in "aggregated_to"  , with: '2021/02/12'
      find('label', text: "集計期間").click #カレンダーを消すために空クリック
      click_on "絞り込み"
      expect(all(:css, 'tbody > tr').size).to eq(1)
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(6)', text: '10')       # 60 - 50  #投稿数
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(7)', text: '1,000')    # 4000 - 3000 #反応数
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(7)', text: '33.3333%') # 1000 / 3000 * 100 #反応数増加率
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(8)', text: '800')      # 1800 - 1000  #フォロワー増加数
      expect(first(:css, 'tbody > tr')).to have_selector('td:nth-child(8)', text: '80.0%')    # 800 / 1000 * 100  #フォロワー増加率
    end
  end

  context "並び替え" do
    background do
      # account_id: 1, date: 2021/2/10, follower: 1000, post_count: 50, total_reaction: 3000
      # ↑最上部backgroundで定義
      # account_id: 1, date: 2021/2/11, follower: 1100, post_count: 60, total_reaction: 4500
      FactoryBot.create(:daily_account_engagement, date: '2021/2/11'.to_date, follower: 1100, post_count: 60, total_reaction: 4500)
      # 直近1週間前のデータ想定 account_id: 1, date: 2021/2/05, follower: 0, post_count: 0, total_reaction: 0
      FactoryBot.create(:daily_account_engagement, date: '2021/2/05'.to_date, follower: 0, post_count: 0, total_reaction: 0)
      @account2 = FactoryBot.create(:account, name: 'アカウント2', max_posted_at: '2021/2/28'.to_date) do |account|
        # account_id: 2, date: 2021/2/10, follower: 1200, post_count: 5,   total_reaction: 1800
        FactoryBot.create(:daily_account_engagement, account_id: account.id, follower: 1200, post_count: 5, total_reaction: 1800)
        # account_id: 2, date: 2021/2/10, follower: 1400, post_count: 100, total_reaction: 2000
        FactoryBot.create(:daily_account_engagement, account_id: account.id, date: '2021/2/11'.to_date, follower: 1310, post_count: 100, total_reaction: 2000)
        # 直近1週間前のデータ想定 account_id: 2, date: 2021/2/05, follower: 0, post_count: 0, total_reaction: 0
        FactoryBot.create(:daily_account_engagement, account_id: account.id, date: '2021/2/05'.to_date, follower: 0, post_count: 0, total_reaction: 0)
      end
      @account3 = FactoryBot.create(:account, name: 'アカウント3', max_posted_at: '2021/2/5'.to_date) do |account|
        # account_id: 3, date: 2021/2/10, follower: 10,   post_count: 250, total_reaction: 700
        FactoryBot.create(:daily_account_engagement, account_id: account.id, follower: 10, post_count: 250, total_reaction: 700)
        # account_id: 3, date: 2021/2/11, follower: 1000, post_count: 300, total_reaction: 2100
        FactoryBot.create(:daily_account_engagement, account_id: account.id, date: '2021/2/11'.to_date, follower: 1000, post_count: 300, total_reaction: 2100)
        # 直近1週間前のデータ想定 account_id: 3, date: 2021/2/05, follower: 0, post_count: 0, total_reaction: 0
        FactoryBot.create(:daily_account_engagement, account_id: account.id, date: '2021/2/05'.to_date, follower: 0, post_count: 0, total_reaction: 0)
      end
      click_on "アカウント検索"
      find('.sidenav-normal', text: '全SNS').click
      expect(all(:css, 'tbody > tr').size).to eq(3)
      # ↓デフォルトは直近1週間のフォロワー増加数が多い順
      expect(first(:css, 'tbody > tr')).to  have_content 'アカウント2'
      expect(all(:css, 'tbody > tr')[1]).to have_content 'アカウント1'
      expect(all(:css, 'tbody > tr')[2]).to have_content 'アカウント3'
      find('span', text: "絞り込みフォーム").click
      fill_in "aggregated_from", with: '2021/02/10'
      fill_in "aggregated_to",   with: '2021/02/11'
      find('label', text: "集計期間").click #カレンダーを消すために空クリック
    end

    context "フォロワー増加数で並び替え" do
      scenario "集計期間でのフォロワー増加数が多い順に表示される" do
        select 'フォロワー増加数', from: "sort"
        click_on "絞り込み"
        expect(all(:css, 'tbody > tr').size).to eq(3)
        expect(first(:css, 'tbody > tr')).to  have_content 'アカウント3'
        expect(all(:css, 'tbody > tr')[1]).to have_content 'アカウント2'
        expect(all(:css, 'tbody > tr')[2]).to have_content 'アカウント1'
      end
    end

    context "投稿数で並び替え" do
      scenario "集計期間での投稿数が多い順に表示される" do
        select '投稿数', from: "sort"
        click_on "絞り込み"
        expect(all(:css, 'tbody > tr').size).to eq(3)
        expect(first(:css, 'tbody > tr')).to  have_content 'アカウント2'
        expect(all(:css, 'tbody > tr')[1]).to have_content 'アカウント3'
        expect(all(:css, 'tbody > tr')[2]).to have_content 'アカウント1'
      end
    end

    context "フォロワー増加率で並び替え" do
      scenario "集計期間でのフォロワー増加率が多い順に表示される" do
        select 'フォロワー増加率', from: "sort"
        click_on "絞り込み"
        expect(all(:css, 'tbody > tr').size).to eq(3)
        expect(first(:css, 'tbody > tr')).to  have_content 'アカウント3'
        expect(all(:css, 'tbody > tr')[1]).to have_content 'アカウント1'
        expect(all(:css, 'tbody > tr')[2]).to have_content 'アカウント2'
      end
    end

    context "反応数で並び替え" do
      scenario "集計期間での反応数が多い順に表示される" do
        select '反応数', from: "sort"
        click_on "絞り込み"
        expect(all(:css, 'tbody > tr').size).to eq(3)
        expect(first(:css, 'tbody > tr')).to  have_content 'アカウント1'
        expect(all(:css, 'tbody > tr')[1]).to have_content 'アカウント3'
        expect(all(:css, 'tbody > tr')[2]).to have_content 'アカウント2'
      end
    end

    context "反応数増加率で並び替え" do
      scenario "集計期間での反応数増加率が多い順に表示される" do
        select '反応数増加率', from: "sort"
        click_on "絞り込み"
        expect(all(:css, 'tbody > tr').size).to eq(3)
        expect(first(:css, 'tbody > tr')).to  have_content 'アカウント3'
        expect(all(:css, 'tbody > tr')[1]).to have_content 'アカウント1'
        expect(all(:css, 'tbody > tr')[2]).to have_content 'アカウント2'
      end
    end

    context "最新投稿日で並び替え" do
      scenario "最新投稿日が若い順に表示される" do
        select '最新投稿日', from: "sort"
        click_on "絞り込み"
        expect(all(:css, 'tbody > tr').size).to eq(3)
        expect(first(:css, 'tbody > tr')).to  have_content 'アカウント1'
        expect(all(:css, 'tbody > tr')[1]).to have_content 'アカウント2'
        expect(all(:css, 'tbody > tr')[2]).to have_content 'アカウント3'
      end
    end
  end

  scenario "絞込みフォームに入力した項目がpost後も入力されている" do
    click_on "アカウント検索"
    find('.sidenav-normal', text: '全SNS').click
    find('span', text: "絞り込みフォーム").click
    fill_in 'search_account', with: "アカウント"
    select 'LINE', from: "media"
    select 'フォロワー増加数', from: "sort"
    fill_in "aggregated_from", with: '2021/02/10'
    fill_in "aggregated_to"  , with: '2021/02/12'
    find('label', text: "集計期間").click #カレンダーを消すために空クリック
    click_on '絞り込み'
    expect(find('#search_account').value).to eq 'アカウント'
    expect(find('#media').value).to eq 'LINE'
    expect(find('#sort').value).not_to eq ''
    expect(find('#aggregated_from').value).to eq '2021/02/10'
    expect(find('#aggregated_to').value).to eq '2021/02/12'
  end

  context "ピンアカ機能" do
    context "ピンアカ登録、削除" do
      scenario "☆クリックでピンアカ登録/削除の切り替え" do
        5.times do
          FactoryBot.create(:account)
        end
        click_on "アカウント検索"
        find('.sidenav-normal', text: '全SNS').click
        expect(all(:css, 'tbody > tr').size).to eq(6)
        expect(Favorite.all.size).to eq(0)
        first('tbody > tr > td > a .fa-star').click # 何故か'#favorite_1'とid指定すると☆がON状態の場合に見つからないというエラーが出るため、cssで指定している。
        all('tbody > tr > td > a .fa-star')[1].click
        all('tbody > tr > td > a .fa-star')[2].click
        sleep 1
        expect(Favorite.all.size).to eq(3)
        sleep 1
        first('tbody > tr > td > a .fa-star').click
        all('tbody > tr > td > a .fa-star')[1].click
        sleep 3
        expect(Favorite.all.size).to eq(1)
      end
    end
    context "ピンアカスイッチで絞り込み" do
      background do
        # どのユーザーもピンアカに登録していないアカウントを5個作成
        5.times do
          FactoryBot.create(:account)
        end

        # user(id:2)がピンアカに登録しているアカウントを10個作成
        FactoryBot.create(:user, email: 'tester2@example.com')
        10.times do
          FactoryBot.create(:account) do |account|
            FactoryBot.create(:favorite, user_id: 2, account_id: account.id)
          end
        end

        # user(id:1)がピンアカに登録しているアカウントを10個作成
        20.times do
          FactoryBot.create(:account) do |account|
            FactoryBot.create(:favorite, account_id: account.id)
          end
        end
        click_on "アカウント検索"
        find('.sidenav-normal', text: '全SNS').click
        expect(all(:css, 'tbody > tr').size).to eq(36)
      end

      scenario "ピンアカスイッチONでピンアカのみ表示、OFFで解除" do
        find('span', text: "絞り込みフォーム").click
        find('label', text: "Off").click
        click_on '絞り込み'
        expect(all(:css, 'tbody > tr').size).to eq(20)
        find('label', text: "On").click
        click_on '絞り込み'
        expect(all(:css, 'tbody > tr').size).to eq(36)
      end
    end
  end
end
