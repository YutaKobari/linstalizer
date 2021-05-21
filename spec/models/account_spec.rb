require 'rails_helper'

RSpec.describe Account, type: :model do
  before do
    FactoryBot.create(:company)
    FactoryBot.create(:market)
    FactoryBot.create(:brand)
    @account = FactoryBot.create(:account)

    FactoryBot.create(:brand)
    FactoryBot.create(:account, brand_id: 2)
    @today = Date.today
    @graph_aggregated_from = 29.days.ago.to_date
    @params = { graph_aggregated_from: @graph_aggregated_from, graph_aggregated_to: @today }
  end

  describe 'fetch_follower_per_dateのテスト' do
    before do
      FactoryBot.create(:daily_account_engagement, date: @today)
    end
    context 'オプションなしの場合' do
      example '日付とフォロワー数のペアが正常に返ってくる' do
        follower_per_date_data = @account.fetch_follower_per_date(@params)
        expect(follower_per_date_data.size).to eq 30 # 日数分のデータが返ってくる
        existing_follower_per_date_data = follower_per_date_data.reject { |d| d[:value].nil? }
        expect(existing_follower_per_date_data.size).to eq 1
        expect(existing_follower_per_date_data[0]).to eq({ date: @today.to_s, value: 1000 })
      end
      example 'アカウントIDが一致しないものはカウントされない' do
        FactoryBot.create(:daily_account_engagement, account_id: 2)
        follower_per_date_data = @account.fetch_follower_per_date(@params)
        existing_follower_per_date_data = follower_per_date_data.reject { |d| d[:value].nil? }
        expect(existing_follower_per_date_data.size).to eq 1
      end
      example '指定された期間外のものはカウントされない' do
        FactoryBot.create(:daily_account_engagement, date: 1.years.ago.to_date)
        params = { graph_aggregated_from: 1.years.ago.to_date, graph_aggregated_to: (1.years - 6.days).ago.to_date }
        follower_per_date_data = @account.fetch_follower_per_date(params)
        existing_follower_per_date_data = follower_per_date_data.reject { |d| d[:value].nil? }
        expect(existing_follower_per_date_data.size).to eq 1
      end
    end
    context 'relative: trueのみを渡すとき(単位％、初日比)' do
      example '日付と"フォロワー数 * 100 / 期間初日のフォロワー数"のペアが正常に返ってくる' do
        base_value = 30
        FactoryBot.create(:daily_account_engagement, date: @graph_aggregated_from, follower: base_value) # 期間初日のデータ
        follower_per_date_data = @account.fetch_follower_per_date(@params, relative: true)
        expect(follower_per_date_data.size).to eq 30 # 日数分のデータが返ってくる
        existing_follower_per_date_data = follower_per_date_data.reject { |d| d[:value].nil? }
        expect(existing_follower_per_date_data.size).to eq 2
        expect(existing_follower_per_date_data[0]).to eq({ date: @graph_aggregated_from.to_s, value: 100.0 }) # 基準となる初日は100になる
        expect(existing_follower_per_date_data[1]).to eq({ date: @today.to_s, value: 1000 * 100.0 / base_value })
      end
      skip '期間初日のデータが存在しない場合、いまのところは何も表示されないので保留' do
      end
    end
    context 'increment: trueのみを渡すとき(前日からの増分絶対値)' do
      example '日付と"フォロワー数 - 前日のフォロワー数"のペアが正常に返ってくる' do
        base_value = 30
        FactoryBot.create(:daily_account_engagement, date: @today - 1, follower: base_value) # 前日のデータ
        follower_per_date_data = @account.fetch_follower_per_date(@params, increment: true)
        expect(follower_per_date_data.size).to eq 30 # 日数分のデータが返ってくる
        existing_follower_per_date_data = follower_per_date_data.reject { |d| d[:value].nil? }
        expect(existing_follower_per_date_data.size).to eq 1 # 1つ前のデータ或いは該当のデータがnilなら比較しない（nil）
        expect(existing_follower_per_date_data[0]).to eq({ date: @today.to_s, value: (1000 - base_value) })
      end
    end
    context 'relative: true, increment: trueのとき（前日からの増分、単位％）' do
      example '日付と"(フォロワー数 - 前日のフォロワー数) * 100 / 前日のフォロワー数"のペアが正常に返ってくる' do
        base_value = 30
        FactoryBot.create(:daily_account_engagement, date: @today - 1, follower: base_value) # 前日のデータ
        follower_per_date_data = @account.fetch_follower_per_date(@params, relative: true, increment: true)
        expect(follower_per_date_data.size).to eq 30 # 日数分のデータが返ってくる
        existing_follower_per_date_data = follower_per_date_data.reject { |d| d[:value].nil? }
        expect(existing_follower_per_date_data.size).to eq 1 # 1つ前のデータ或いは該当のデータがnilなら比較しない（nil）ため
        expect(existing_follower_per_date_data[0]).to eq({ date: @today.to_s, value: (1000 - base_value) * 100.0 / base_value })
      end
    end
  end

  describe 'posts_per_dateのテスト' do
    before do
      FactoryBot.create(:post, posted_on: @today, media: 'LINE')
      FactoryBot.create(:post, posted_on: @today, media: 'Instagram')
    end
    example '投稿日とSNSでグループ化された投稿数の合計が返ってくる' do
      posts_data = JSON.parse(@account.posts_per_date(@params))
      expect(posts_data).to include({ 'media' => 'LINE', 'posted_on' => @today.strftime, 'sum' => 1 })
      expect(posts_data).to include({ 'media' => 'Instagram', 'posted_on' => @today.strftime, 'sum' => 1 })
    end
    example '投稿日、SNSが同じ投稿が複数あると投稿数の合計に加算される' do
      FactoryBot.create(:post, posted_on: @today, media: 'Instagram')
      FactoryBot.create(:post, posted_on: @today, media: 'Instagram')
      FactoryBot.create(:post, posted_on: @today, media: 'Instagram')
      posts_data = JSON.parse(@account.posts_per_date(@params))
      expect(posts_data).to include({ 'media' => 'Instagram', 'posted_on' => @today.strftime, 'sum' => 4 })
    end
    example 'アカウントIDが一致しないものはカウントされない' do
      FactoryBot.create(:post, posted_on: @today, media: 'LINE', account_id: 2)
      posts_data = JSON.parse(@account.posts_per_date(@params))
      expect(posts_data).not_to include({ 'media' => 'LINE', 'posted_on' => @today.strftime, 'sum' => 2 })
      expect(posts_data).to include({ 'media' => 'LINE', 'posted_on' => @today.strftime, 'sum' => 1 })
    end
  end

  describe 'talk_posts_per_dateのテスト' do
    before do
      FactoryBot.create(:talk_post, posted_on: @today)
    end
    example '投稿日でグループ化された投稿数の合計が返ってくる' do # mediaは一律LINE
      talk_posts_data = JSON.parse(@account.talk_posts_per_date(@params))
      expect(talk_posts_data).to include({ 'media' => 'LINE', 'posted_on' => @today.strftime, 'sum' => 1 })
    end
    example '同じ投稿日の投稿が複数あると投稿数の合計に加算される' do
      FactoryBot.create(:talk_post, posted_on: @today)
      FactoryBot.create(:talk_post, posted_on: @today)
      talk_posts_data = JSON.parse(@account.talk_posts_per_date(@params))
      expect(talk_posts_data).to include({ 'media' => 'LINE', 'posted_on' => @today.strftime, 'sum' => 3 })
    end
    example 'アカウントIDが一致しないものはカウントされない' do
      FactoryBot.create(:talk_post, posted_on: @today - 3.days, account_id: 2)
      posts_data = JSON.parse(@account.talk_posts_per_date(@params))
      expect(posts_data).not_to include({ 'media' => 'LINE', 'posted_on' => (@today - 3.days).strftime, 'sum' => 1 })
    end
  end
end
