require 'rails_helper'

RSpec.describe Brand, type: :model do
  before do
    FactoryBot.create(:company)
    FactoryBot.create(:market)
    @brand = FactoryBot.create(:brand)
    FactoryBot.create(:account)

    FactoryBot.create(:brand)
    FactoryBot.create(:account, brand_id: 2)
    @today = Date.today
    @graph_aggregated_from = 29.days.ago.to_date
    @params = {graph_aggregated_from: @graph_aggregated_from, graph_aggregated_to: @today}
  end

  describe "brandlift_per_dateのテスト" do
    before do
      FactoryBot.create(:brand_lift_value, date: @today,          value: 100)
    end
    context 'オプションなしのとき' do
      example "日付とブランドTOPIXのペアが正常に返ってくる" do
        brandlift_data = @brand.brandlift_per_date(@params, 2)
        expect(brandlift_data.size).to eq 30 # 日数分のデータが返ってくる
        existing_brandlift_data = brandlift_data.reject{ |d| d[:value].nil? }
        expect(existing_brandlift_data.size).to eq 1
        expect(existing_brandlift_data[0]).to eq ({date: @today.to_s,            value: 100})
      end
      example "ブランドIDが一致しないものはカウントされない" do
        FactoryBot.create(:brand_lift_value, brand_id: 2)
        brandlift_data = @brand.brandlift_per_date(@params, 2)
        existing_brandlift_data = brandlift_data.reject{ |d| d[:value].nil? }
        expect(existing_brandlift_data.size).to eq 1
      end
      example "指定された期間外のものはカウントされない" do
        FactoryBot.create(:brand_lift_value, date: 1.years.ago.to_date)
        params = {graph_aggregated_from: 1.years.ago.to_date, graph_aggregated_to: ((1.years - 6.days).ago.to_date)}
        brandlift_data = @brand.brandlift_per_date(params, 2)
        existing_brandlift_data = brandlift_data.reject{ |d| d[:value].nil? }
        expect(existing_brandlift_data.size).to eq 1
      end
    end
    context 'relative: trueのとき（初日比較、単位％）' do
      example '日付と"(ブランドTOPIX * 100) / 期間初日のデータ"のペアが正常に返ってくる' do
        base_value = 15
        FactoryBot.create(:brand_lift_value, date: @graph_aggregated_from, value: base_value) # 期間初日のデータ
        brandlift_data = @brand.brandlift_per_date(@params, 2, relative: true)
        expect(brandlift_data.size).to eq 30 # 日数分のデータが返ってくる
        existing_brandlift_data = brandlift_data.reject{ |d| d[:value].nil? }
        expect(existing_brandlift_data.size).to eq 2
        expect(existing_brandlift_data[0]).to eq({date: @graph_aggregated_from.to_s, value: 100.0}) # 基準となる初日は100になる
        expect(existing_brandlift_data[1]).to eq({date: @today.to_s, value: 100 * 100.0 / base_value})
      end
      skip '期間初日のデータが存在しない場合、いまのところは何も表示されないので保留' do
      end
    end
    context 'increment: trueのとき（前日からの増分絶対値）' do
      example '日付と"ブランドTOPIX - 前日のブランドTOPIX"のペアが正常に返ってくる' do
        base_value = 15
        FactoryBot.create(:brand_lift_value, date: @today - 1, value: base_value) # 1つ前のデータ
        brandlift_data = @brand.brandlift_per_date(@params, 2, increment: true)
        expect(brandlift_data.size).to eq 30 # 日数分のデータが返ってくる
        existing_brandlift_data = brandlift_data.reject{ |d| d[:value].nil? }
        expect(existing_brandlift_data.size).to eq 1 # 1つ前か該当のデータがない場合はnilになるため
        expect(existing_brandlift_data[0]).to eq({date: @today.to_s, value: 100 - base_value})
      end
    end
    context 'relative: true, increment: trueのとき（前日からの増分、単位%）' do
      example '日付と"(ブランドTOPIX - 前日のブランドTOPIX) * 100 / 前日のブランドTOPIX"のペアが正常に返ってくる' do
        base_value = 15
        FactoryBot.create(:brand_lift_value, date: @today - 1, value: base_value) # 1つ前のデータ
        brandlift_data = @brand.brandlift_per_date(@params, 2, relative: true, increment: true)
        expect(brandlift_data.size).to eq 30 # 日数分のデータが返ってくる
        existing_brandlift_data = brandlift_data.reject{ |d| d[:value].nil? }
        expect(existing_brandlift_data.size).to eq 1 # 1つ前か該当のデータがない場合はnilになるため
        expect(existing_brandlift_data[0]).to eq({date: @today.to_s, value: (100 - base_value) * 100.0 / base_value})
      end
    end
  end

  describe "posts_per_dateのテスト" do
    before do
      FactoryBot.create(:post, posted_on: @today, media: "LINE")
      FactoryBot.create(:post, posted_on: @today, media: "Instagram")
    end
    example "投稿日とSNSでグループ化された投稿数の合計が返ってくる" do
      posts_data = JSON.parse(@brand.posts_per_date(@params))
      expect(posts_data).to include({"media" => "LINE", "posted_on" => @today.strftime, "sum" => 1})
      expect(posts_data).to include({"media" => "Instagram", "posted_on" => @today.strftime, "sum" => 1})
    end
    example "投稿日、SNSが同じ投稿が複数あると投稿数の合計に加算される" do
      FactoryBot.create(:post, posted_on: @today, media: "Instagram")
      FactoryBot.create(:post, posted_on: @today, media: "Instagram")
      FactoryBot.create(:post, posted_on: @today, media: "Instagram")
      posts_data = JSON.parse(@brand.posts_per_date(@params))
      expect(posts_data).to include({"media" => "Instagram", "posted_on" => @today.strftime, "sum" => 4})
    end
    example "ブランドIDが一致しないものはカウントされない" do
      FactoryBot.create(:post, posted_on: @today, media: "LINE", brand_id: 2)
      posts_data = JSON.parse(@brand.posts_per_date(@params))
      expect(posts_data).not_to include({"media" => "LINE", "posted_on" => @today.strftime, "sum" => 2})
      expect(posts_data).to include({"media" => "LINE", "posted_on" => @today.strftime, "sum" => 1})
    end
  end

  describe "talk_posts_per_dateのテスト" do
    before do
      FactoryBot.create(:talk_post, posted_on: @today)
    end
    example "投稿日でグループ化された投稿数の合計が返ってくる" do # mediaは一律LINE
      talk_posts_data = JSON.parse(@brand.talk_posts_per_date(@params))
      expect(talk_posts_data).to include({"media" => "LINE", "posted_on" => @today.strftime, "sum" => 1})
    end
    example "同じ投稿日の投稿が複数あると投稿数の合計に加算される" do
      FactoryBot.create(:talk_post, posted_on: @today)
      FactoryBot.create(:talk_post, posted_on: @today)
      talk_posts_data = JSON.parse(@brand.talk_posts_per_date(@params))
      expect(talk_posts_data).to include({"media" => "LINE", "posted_on" => @today.strftime, "sum" => 3})
    end
    example "ブランドIDが一致しないものはカウントされない" do
      FactoryBot.create(:talk_post, posted_on: @today - 3.days, brand_id: 2)
      posts_data = JSON.parse(@brand.talk_posts_per_date(@params))
      expect(posts_data).not_to include({"media" => "LINE", "posted_on" => (@today - 3.days).strftime, "sum" => 1})
    end
  end
end
