require 'rails_helper'

feature "ハッシュタグ一覧画面" do
   given(:email)    { 'tester@example.com' }
   given(:password) { '000000' }

  background do
    FactoryBot.create(:user)
    FactoryBot.create(:company)
    FactoryBot.create(:market)
    FactoryBot.create(:brand)
    FactoryBot.create(:account)
    visit root_path
    fill_in "user_email",    with: email
    fill_in "user_password", with: password
    click_on "ログイン"
  end

  scenario "titleタグがパンくずのテキストになっている" do
    click_on "ハッシュタグ一覧"
    find('.sidenav-normal', text: 'ハッシュタグ一覧').click
    expect(page).to have_title 'ハッシュタグ一覧 | SNSクロール'
  end

  scenario 'パンくずリスト' do
    click_on "ハッシュタグ一覧"
    find('.sidenav-normal', text: 'ハッシュタグ一覧').click
    expect(page).to have_selector(".breadcrumb-item", text: 'ハッシュタグ一覧')
  end

  context "遷移" do
    background do
      FactoryBot.create(:hash_tag) # id: 1, name: ハッシュタグ1
      FactoryBot.create(:post, :with_post_hash_tag1, posted_at: Date.yesterday)
      click_on "ハッシュタグ一覧"
      find('.sidenav-normal', text: 'ハッシュタグ一覧').click
    end
    scenario '行をクリックすると投稿検索画面（絞り込みあり）に遷移' do
      find('tbody > tr', text: 'ハッシュタグ1').click
      within_window(windows.last) do
        expect(page).to have_current_path(posts_path(start_date: Date.today - 6.days, end_date: Date.today, search_hash_tag: 'ハッシュタグ1', media: 'Instagram'))
      end
    end
    scenario '投稿画像をクリックすると投稿詳細画面に遷移' do
      first('tbody > tr:nth-child(1) > td:nth-child(2) img').click
      within_window(windows.last) do
        expect(page).to have_current_path(post_path(1))
      end
    end
    scenario 'SNS名をクリックするとSNS絞り込み画面に遷移' do
      first('tbody > tr > td > span > a', class: 'Instagram_btn').click
      within_window(windows.last) do
        expect(page).to have_current_path(hash_tags_path(media: "Instagram"))
      end
    end
  end

  context "ハッシュタグ名で検索する" do
    background do
      5.times { FactoryBot.create(:post, posted_at: Date.yesterday) }

      FactoryBot.create(:hash_tag) # id: 1, name: ハッシュタグ1
      FactoryBot.create(:post_hash_tag, post_id: 1, hash_tag_id: 1)

      FactoryBot.create(:hash_tag, name: 'ダミー') # id: 2, name: ハッシュタグ1
      FactoryBot.create(:post_hash_tag, post_id: 2, hash_tag_id: 2)

      FactoryBot.create(:hash_tag, name: 'テストhashtag') # id: 3
      FactoryBot.create(:post_hash_tag, post_id: 3, hash_tag_id: 3)
      FactoryBot.create(:post_hash_tag, post_id: 4, hash_tag_id: 3)
      FactoryBot.create(:post_hash_tag, post_id: 5, hash_tag_id: 3)

      click_on "ハッシュタグ一覧"
      find('.sidenav-normal', text: 'ハッシュタグ一覧').click
    end
    scenario '入力ワードを含むハッシュタグが表示される' do
      expect(all('tbody > tr').size).to eq(3)
      find('span', text: "絞り込みフォーム").click
      fill_in 'search_hash_tag', with: "テスト"
      click_on "絞り込み"
      expect(all('tbody > tr').size).to eq(1)
      expect(all('tbody > tr')[0]).to have_content 'テストhashtag'
      expect(all('tbody > tr:nth-child(1) > td:nth-child(2) img').size).to eq 3
    end
  end

  context "SNSを指定" do
    background do
      3.times { FactoryBot.create(:post, posted_at: Date.yesterday) }

      FactoryBot.create(:hash_tag) # id: 1, name: ハッシュタグ1
      FactoryBot.create(:post_hash_tag, post_id: 1, hash_tag_id: 1)

      FactoryBot.create(:hash_tag, name: 'hashtag') # id: 2, name: ハッシュタグ1
      FactoryBot.create(:post_hash_tag, post_id: 2, hash_tag_id: 2)

      FactoryBot.create(:hash_tag, name: 'hashtag', media: "LINE") # id: 3
      FactoryBot.create(:post_hash_tag, post_id: 3, hash_tag_id: 3)

      click_on "ハッシュタグ一覧"
      find('.sidenav-normal', text: 'ハッシュタグ一覧').click
    end

    scenario '選択したSNSのみのハッシュタグが表示される' do
      expect(all('tbody > tr').size).to eq(3)
      find('span', text: "絞り込みフォーム").click
      select 'LINE', from: 'media'
      click_on "絞り込み"
      expect(all('tbody > tr').size).to eq(1)

      select 'Instagram', from: 'media'
      click_on "絞り込み"
      expect(all('tbody > tr').size).to eq(2)

      select '全SNS', from: 'media'
      click_on "絞り込み"
      expect(all('tbody > tr').size).to eq(3)
    end
  end

  context "集計期間を指定" do
    background do
      FactoryBot.create(:hash_tag) # id: 1, name: ハッシュタグ1

      2.times { FactoryBot.create(:post, :with_post_hash_tag1, posted_at: Date.today, like_count: 10000) }
      3.times { FactoryBot.create(:post, :with_post_hash_tag1, posted_at: Date.yesterday, like_count: 1000) }
      4.times { FactoryBot.create(:post, :with_post_hash_tag1, posted_at: Date.today - 10.days, like_count: 100) }
      6.times { FactoryBot.create(:post, :with_post_hash_tag1, posted_at: Date.today - 1.month, like_count: 10) }
      7.times { FactoryBot.create(:post, :with_post_hash_tag1, posted_at: '2021/3/10'.to_date, like_count: 1) }

      click_on "ハッシュタグ一覧"
      find('.sidenav-normal', text: 'ハッシュタグ一覧').click
    end

    scenario '全期間をクリックすると2021/02/01から今日の日付がセットされる' do
      find('span', text: "絞り込みフォーム").click
      find('#all_periods_aggregation').click
      expect(find('#aggregated_from').value).to eq '2021/02/01'
      expect(find('#aggregated_to').value).to eq I18n.l((Time.now).to_date)
    end

    scenario "1週間をクリックすると直近1週間の日付がセットされる" do
      find('span', text: "絞り込みフォーム").click
      find('#one_week_aggregation').click
      expect(find('#aggregated_from').value).to eq I18n.l((Time.now - 6.days).to_date)
      expect(find('#aggregated_to').value).to eq I18n.l((Time.now).to_date)
    end

    scenario "デフォルトで直近1週間の集計値が返ってくる" do
      expect(all('tbody > tr').size).to eq(1)
      expect(first('tbody > tr')).to have_selector('td:nth-child(3)', text: '5') #投稿数
      expect(first('tbody > tr')).to have_selector('td:nth-child(4)', text: '23,000') #反応数
    end
    scenario "集計開始日のみ指定すると指定日から今日までの集計値が返ってくる" do
      expect(all('tbody > tr').size).to eq(1)
      find('span', text: "絞り込みフォーム").click
      fill_in "aggregated_from", with: Date.today - 10.days
      click_on "絞り込み"
      expect(all('tbody > tr').size).to eq(1)
      expect(first('tbody > tr')).to have_selector('td:nth-child(3)', text: '9') #投稿数
      expect(first('tbody > tr')).to have_selector('td:nth-child(4)', text: '23,400') #反応数
    end
    scenario "指定した集計期間での集計値が返ってくる" do
      expect(all(:css, 'tbody > tr').size).to eq(1)
      find('span', text: "絞り込みフォーム").click
      fill_in "aggregated_from", with: Date.today - 1.month
      fill_in "aggregated_to"  , with: Date.today - 10.days
      find('label', text: "集計期間").click #カレンダーを消すために空クリック
      click_on "絞り込み"
      expect(all('tbody > tr').size).to eq(1)
      expect(first('tbody > tr')).to have_selector('td:nth-child(3)', text: '10') #投稿数
      expect(first('tbody > tr')).to have_selector('td:nth-child(4)', text: '460') #反応数
    end
  end

  context "並び替え" do
    background do
      FactoryBot.create(:hash_tag) # id: 1, name: ハッシュタグ1
      5.times { FactoryBot.create(:post, :with_post_hash_tag1, posted_at: Date.yesterday, like_count: 100) }
      5.times { FactoryBot.create(:post, :with_post_hash_tag1, posted_at: Date.today - 2.days, like_count: 100) }

      FactoryBot.create(:hash_tag, name: 'ハッシュタグ2') # id: 2, name: ハッシュタグ2
      3.times { FactoryBot.create(:post, :with_post_hash_tag2, posted_at: Date.yesterday, like_count: 10) }
      10.times { FactoryBot.create(:post, :with_post_hash_tag2, posted_at: Date.today - 2.days, like_count: 10) }

      FactoryBot.create(:hash_tag, name: 'ハッシュタグ3') # id: 3, name: ハッシュタグ3
      2.times { FactoryBot.create(:post, :with_post_hash_tag3, posted_at: Date.yesterday, like_count: 1000) }
      2.times { FactoryBot.create(:post, :with_post_hash_tag3, posted_at: Date.today - 2.days, like_count: 1000) }

      click_on "ハッシュタグ一覧"
      find('.sidenav-normal', text: 'ハッシュタグ一覧').click

      expect(all('tbody > tr').size).to eq(3)
      # ↓デフォルトは投稿数が多い順
      expect(first('tbody > tr')).to  have_content 'ハッシュタグ2'
      expect(all('tbody > tr')[1]).to have_content 'ハッシュタグ1'
      expect(all('tbody > tr')[2]).to have_content 'ハッシュタグ3'
      find('span', text: "絞り込みフォーム").click
      fill_in "aggregated_from", with: Date.yesterday
      fill_in "aggregated_to",   with: Date.yesterday
      find('label', text: "集計期間").click #カレンダーを消すために空クリック
    end

    context "投稿数で並び替え" do
      scenario "集計期間での投稿数が多い順に表示される" do
        select '投稿数', from: "sort"
        click_on "絞り込み"
        expect(all('tbody > tr').size).to eq(3)
        expect(first('tbody > tr')).to  have_content 'ハッシュタグ1'
        expect(all('tbody > tr')[1]).to have_content 'ハッシュタグ2'
        expect(all('tbody > tr')[2]).to have_content 'ハッシュタグ3'
      end
    end

    context "反応数で並び替え" do
      scenario "集計期間での反応数が多い順に表示される" do
        select '反応数', from: "sort"
        click_on "絞り込み"
        expect(all('tbody > tr').size).to eq(3)
        expect(first('tbody > tr')).to  have_content 'ハッシュタグ3'
        expect(all('tbody > tr')[1]).to have_content 'ハッシュタグ1'
        expect(all('tbody > tr')[2]).to have_content 'ハッシュタグ2'
      end
    end
  end

  scenario "絞込みフォームに入力した項目がpost後も入力されている" do
    click_on "ハッシュタグ一覧"
    find('.sidenav-normal', text: 'ハッシュタグ一覧').click
    find('span', text: "絞り込みフォーム").click
    fill_in 'search_hash_tag', with: "hogehoge"
    select '反応数', from: "sort"
    fill_in "aggregated_from", with: '2021/02/10'
    fill_in "aggregated_to"  , with: '2021/02/12'
    find('label', text: "集計期間").click #カレンダーを消すために空クリック
    click_on '絞り込み'
    expect(find('#search_hash_tag').value).to eq 'hogehoge'
    expect(find('#sort').value).to eq 'total_reaction_increment'
    expect(find('#aggregated_from').value).to eq '2021/02/10'
    expect(find('#aggregated_to').value).to eq '2021/02/12'
  end
end
