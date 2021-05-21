require 'rails_helper'

feature 'リッチメニュー一覧画面' do
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

  context '遷移' do
    scenario 'サイドナビゲーションから一覧画面へ遷移する' do
      click_on 'LINE投稿'
      find('.sidenav-normal', text: 'リッチメニュー検索').click
      expect(current_path).to eq rich_menus_path
    end
    scenario '初期状態で表示開始日の新しい順に並んでいる' do
      FactoryBot.create(:rich_menu)
      FactoryBot.create(:rich_menu, date_from: '2021/02/03'.to_date)
      FactoryBot.create(:rich_menu, date_from: '2021/02/02'.to_date)
      visit rich_menus_path
      rows = all('tbody tr')
      expect(rows[0]).to have_content I18n.l('2021/02/03'.to_date, format: :long)
      expect(rows[1]).to have_content I18n.l('2021/02/02'.to_date, format: :long)
      expect(rows[2]).to have_content I18n.l('2021/02/01'.to_date, format: :long)
    end
  end

  feature 'リッチメニュー絞り込み機能' do
    background do
      visit rich_menus_path
      find('span', text: '絞り込みフォーム').click
    end

    context 'URL検索' do
      background do
        FactoryBot.create(:lp_combined_url, combined_url: 'http://localhost:3000/#ヒット') do |lp_combined_url|
          FactoryBot.create(:rich_menu) do |rich_menu|
            FactoryBot.create(:rich_menu_content, group_hash: rich_menu.group_hash, url_hash: lp_combined_url.url_hash)
          end
        end
        FactoryBot.create(:rich_menu) do |rich_menu|
          FactoryBot.create(:rich_menu_content, group_hash: rich_menu.group_hash)
        end
        FactoryBot.create(:rich_menu) do |rich_menu|
          FactoryBot.create(:rich_menu_content, group_hash: rich_menu.group_hash)
        end
      end
      scenario 'URLに指定したワードを含む項目のみが出現する' do
        fill_in 'search_url', with: 'ヒット'
        click_on 'commit'
        expect(all('tbody tr').length).to eq 1
      end
    end
    context 'アカウント検索' do
      background do
        FactoryBot.create(:account, name: 'ヒットする部分') { |account| FactoryBot.create(:rich_menu, account_id: account.id) }
        FactoryBot.create(:brand, name: 'ヒットする部分') do |brand|
          FactoryBot.create(:account, brand_id: brand.id) do |account|
            FactoryBot.create(:rich_menu, account_id: account.id)
          end
        end
        FactoryBot.create(:rich_menu)
      end
      scenario 'アカウント名、ブランド名に指定したワードを含む項目のみが出現する' do
        fill_in 'search_account', with: 'ヒット'
        click_on 'commit'
        expect(all('tbody tr').length).to eq 2
      end
    end

    # TODO: 現状、並び替えが一つしかないので、並び替えフィルターは表示していない。
    # context '並び替え' do
    #   background do
    #     FactoryBot.create(:rich_menu)
    #     FactoryBot.create(:rich_menu, date_from: '2021/02/03'.to_date)
    #     FactoryBot.create(:rich_menu, date_from: '2021/02/02'.to_date)
    #   end
    #   scenario '表示開始日が新しい順に並び替え' do
    #     select '表示開始日が新しい順', from: 'sort'
    #     click_on 'commit'
    #     rows = all('tbody tr')
    #     expect(rows[0]).to have_content I18n.l('2021/02/03'.to_date, format: :long)
    #     expect(rows[1]).to have_content I18n.l('2021/02/02'.to_date, format: :long)
    #     expect(rows[2]).to have_content I18n.l('2021/02/01'.to_date, format: :long)
    #   end
    # end

    context '業種検索' do
      scenario '選択した業種だけが表示' do
        pending('ローカルでは通るがbitbucketで落ちる')
        #マーケットがコスメのブランドによる投稿
        FactoryBot.create(:rich_menu)
        FactoryBot.create(:rich_menu)
        #マーケットが飲食のブランドによる投稿
        FactoryBot.create(:rich_menu, account_id: 2)
        FactoryBot.create(:rich_menu, account_id: 2)
        FactoryBot.create(:rich_menu, account_id: 2)
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

    context "ピンアカスイッチで絞り込み" do
      background do
        # どのユーザーもピンアカに登録していないアカウントを2個作成
        2.times do
          FactoryBot.create(:account) do |account|
            # 各アカウントに紐づくrich_menuを4つ作成
            4.times { FactoryBot.create(:rich_menu, account_id: account.id) }
          end
        end

        # user(id:2)がピンアカに登録しているアカウントを3個作成
        FactoryBot.create(:user, email: 'tester2@example.com')
        3.times do
          FactoryBot.create(:account) do |account|
            FactoryBot.create(:favorite, user_id: 2, account_id: account.id)
            # 各アカウントに紐づくrich_menuを2つ作成
            2.times { FactoryBot.create(:rich_menu, account_id: account.id) }
          end
        end

        # user(id:1)がピンアカに登録しているアカウントを4個作成
        4.times do
          FactoryBot.create(:account) do |account|
            FactoryBot.create(:favorite, account_id: account.id)
            # 各アカウントに紐づくrich_menuを5つ作成
            5.times { FactoryBot.create(:rich_menu, account_id: account.id) }
          end
        end
        visit rich_menus_path
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
