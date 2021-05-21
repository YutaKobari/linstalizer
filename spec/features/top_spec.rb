require 'rails_helper'

feature 'トップページ' do
  given(:email)    { 'tester@example.com' }
  given(:password) { '000000' }
  background do
    FactoryBot.create(:user)
    FactoryBot.create(:company)
    FactoryBot.create(:market)
    FactoryBot.create(:brand)
    @account1 = FactoryBot.create(:account)      # id: 1, name: アカウント1
    FactoryBot.create(:daily_account_engagement) # account_id: 1
    FactoryBot.create(:market, name: '飲食') # id = 2
    FactoryBot.create(:brand, name: '飲食のブランド', market_id: 2)
    visit root_path
    fill_in 'user_email',    with: email
    fill_in 'user_password', with: password
    click_on 'ログイン'
  end
  feature 'お知らせ機能' do
    before do
      5.times { FactoryBot.create(:notification, title: 'Active') }
      FactoryBot.create(:notification, :inactive)
      visit root_path
    end
    scenario 'アクティブなお知らせが全て表示される' do
      expect(all('#notifications table tbody tr').length).to eq 5
    end
    scenario 'アクティブでないお知らせは表示されない' do
      expect(page).not_to have_content 'inactive'
    end
  end
  feature 'ピンアカ一覧' do
    context 'ピンアカが10件以下の時' do
      before do
        # ピンアカを3つ作成する
        3.times do
          account = FactoryBot.create(:account, name: 'Favorite')
          FactoryBot.create(:favorite, account_id: account.id)
          visit root_path
        end
      end
      scenario 'ピンアカがすべて表示される' do
        expect(all('#favorite-accounts table tbody tr').length).to eq 3
      end
      scenario 'ピンアカでないアカウントは表示されない' do
        expect(page).not_to have_content 'アカウント1'
      end
      scenario '"すべて表示" は表示されない' do
        expect(page).not_to have_content 'すべて表示'
      end
    end
    context 'ピンアカが10件より多い時' do
      before do
        # ピンアカを11(>10)個作成する
        11.times do
          account = FactoryBot.create(:account)
          FactoryBot.create(:favorite, account_id: account.id)
          visit root_path
        end
      end
      scenario 'ピンアカが10件まで表示される' do
        expect(all('#favorite-accounts table tbody tr').length).to eq 10
      end
      scenario '"すべて表示" が表示される' do
        expect(page).to have_content 'すべて表示'
      end
      scenario 'すべて表示をクリックするとアカウント一覧ページで絞り込みを行った状態へ遷移する' do
        click_link 'すべて表示'
        expect(page).to have_current_path accounts_path(params: { is_favorite: 1, sort: 'max_posted_at' })
        expect(all('table tbody tr').length).to eq 11
      end
    end
  end
  feature 'ピンアカの投稿一覧' do
    before do
      fav_account = FactoryBot.create(:account)
      FactoryBot.create(:favorite, account_id: fav_account.id)
      5.times { FactoryBot.create(:post, :feed, account_id: fav_account.id) }
      FactoryBot.create(:post, :feed) # ピンアカでないアカウントのフィード投稿を作成
      6.times do
        talk = FactoryBot.create(:talk_post, account_id: fav_account.id)
        FactoryBot.create(:talk_post_content, account_id: fav_account.id, talk_group_hash: talk.talk_group_hash)
      end
      # ピンアカでないアカウントのトークを作成
      talk = FactoryBot.create(:talk_post)
      FactoryBot.create(:talk_post_content, talk_group_hash: talk.talk_group_hash)
      visit root_path
    end
    scenario 'はじめは投稿タブがアクティブである' do
      tab = find('.nav-link[data-toggle="tab"].active')
      expect(tab.text).to eq '投稿'
    end
    scenario 'ピンアカの投稿内容が表示される' do
      expect(all('#tabs-1 table tbody tr').length).to eq 5
    end
    scenario 'トークタブへ遷移してリロードするとタブが保持されている' do
      click_on 'tabs-2-tab'
      sleep 1 # 待たないとCookieが発行されない？
      visit current_path
      sleep 1 # 待たないとタブが遷移する前に読んでしまう
      tab = find('.nav-link[data-toggle="tab"].active')
      expect(tab.text).to eq 'トーク'
    end
    scenario 'ピンアカのトーク内容が表示される' do
      click_on 'tabs-2-tab'
      expect(all('#tabs-2 table tbody tr').length).to eq 6
    end
  end
end
