require 'rails_helper'

RSpec.describe Heatmap, type: :model do

  before do
    FactoryBot.create(:company)
    FactoryBot.create(:market)
    @brand = FactoryBot.create(:brand)
    FactoryBot.create(:account)
  end

  describe "post_data_hashesのテスト" do
    context "条件を何も指定しない" do
      before do
        FactoryBot.create(:post)
        FactoryBot.create(:post, posted_at: Date.today)
        FactoryBot.create(:post, :reel)
        FactoryBot.create(:post, :reel, posted_at: Date.today.beginning_of_month)
        @heatmap = Heatmap.new(@brand, {})
      end
      example "今月のレコードが返ってくる" do
        post_data = @heatmap.post_data_hashes
        expect(post_data.size).to eq 2
        expect(post_data.map{|d| d[:post_type]}).to eq ["feed", "reel"]
      end
    end

    context "aggregated_from, aggregated_toで期間を絞り込む" do
      before do
        FactoryBot.create(:post, posted_at: Date.today)
        FactoryBot.create(:post, :story, posted_at: "2021/01/01")
        @heatmap = Heatmap.new(@brand, aggregated_from: "2021/01/01", aggregated_to: "2021/01/02")
      end
      example "期間中に投稿された投稿が返ってくる" do
        post_data = @heatmap.post_data_hashes
        expect(post_data.size).to eq 1
        expect(post_data.first[:post_type]).to eq "story"
      end
    end

    context "投稿タイプで絞り込む" do
      before do
        FactoryBot.create(:post, :feed)
        FactoryBot.create(:post, :reel)
        FactoryBot.create(:post, :retweet)
        @heatmap = Heatmap.new(@brand, media_post_types: ["Instagram-reel", "Twitter-retweet"], aggregated_from: "2021/02/01", aggregated_to: "2021/02/02")
      end
      example "投稿タイプが一致した投稿が返ってくる" do
        post_data = @heatmap.post_data_hashes
        expect(post_data.size).to eq 2
        expect(post_data.map{|d| d[:post_type]}).to eq ["reel", "retweet"]
      end
    end
  end

  describe "post_data_per_hourメソッドのテスト" do
    example "指定した時間帯の投稿数が正しく取得できる" do
      FactoryBot.create(:post, day: 0, hour: 0)
      FactoryBot.create(:post, day: 0, hour: 0)
      FactoryBot.create(:post, day: 0, hour: 0)
      heatmap = Heatmap.new(@brand, aggregated_from: "2021/02/01", aggregated_to: "2021/02/02")
      post_data = heatmap.post_data_per_hour(day: 0, hour:0)
      expect(post_data.first[:post_count]).to eq 3
      expect(post_data.last).to eq 3 # 配列の最後にはその時間帯の投稿数の合計が入る
    end

    example "複数の投稿タイプでも投稿数が正しく取得できる" do
      FactoryBot.create(:post, day: 0, hour: 0)
      FactoryBot.create(:post, day: 0, hour: 0)
      FactoryBot.create(:post, :reel, day: 0, hour: 0)
      heatmap = Heatmap.new(@brand, aggregated_from: "2021/02/01", aggregated_to: "2021/02/02")
      post_data = heatmap.post_data_per_hour(day: 0, hour:0)
      expect(post_data.first[:post_count]).to eq 2
      expect(post_data.second[:post_count]).to eq 1
      expect(post_data.last).to eq 3 # 配列の最後にはその時間帯の投稿数の合計が入る
    end
  end

  describe "max_post_count_per_hourのテスト" do
    example "時間帯ごとの投稿数の最大値を正しく取得できるか" do
      FactoryBot.create(:post, day: 0, hour: 0)
      4.times  { FactoryBot.create(:post, day: 0, hour: 0) } # 月曜0~1時: 5コ
      10.times { FactoryBot.create(:post, day: 1, hour: 0) } # 火曜0~1時: 10コ
      5.times  { FactoryBot.create(:post, day: 2, hour: 0) }
      10.times { FactoryBot.create(:post, :story, day: 2, hour: 0) } # 水曜0~1時: feed 5 + story 10 = 15コ

      heatmap = Heatmap.new(@brand, aggregated_from: "2021/02/01", aggregated_to: "2021/02/02")
      expect(heatmap.max_post_count_per_hour).to eq 15
    end

    example "投稿タイプで絞り込みを行っても時間帯ごとの投稿数の最大値を正しく取得できるか" do
      FactoryBot.create(:post, day: 0, hour: 0)
      4.times  { FactoryBot.create(:post, :feed,  day: 0, hour: 0) } # 1. 月曜0~1時: 5コ
      10.times { FactoryBot.create(:post, :feed,  day: 1, hour: 0) } # 2. 火曜0~1時: 10コ
      5.times  { FactoryBot.create(:post, :feed,  day: 2, hour: 0) }
      10.times { FactoryBot.create(:post, :story, day: 2, hour: 0) } # 3. 水曜0~1時: feed 5 + story 10 = 15コ

      heatmap = Heatmap.new(@brand, media_post_types: ["Instagram-feed"], aggregated_from: "2021/02/01", aggregated_to: "2021/02/02")
      expect(heatmap.max_post_count_per_hour).to eq 10 # storyは除外するため2の10コが最大値
    end

    example "期間で絞り込みを行っても時間帯ごとの投稿数の最大値を正しく取得できるか" do
      FactoryBot.create(:post, day: 0, hour: 0)
      4.times  { FactoryBot.create(:post, day: 0, hour: 0) } # 1. 月曜0~1時: 5コ
      10.times { FactoryBot.create(:post, day: 1, hour: 0) } # 2. 火曜0~1時: 10コ
      5.times  { FactoryBot.create(:post, day: 2, hour: 0) }
      10.times { FactoryBot.create(:post, day: 2, hour: 0, posted_at: "2100/01/01") } # 3. 水曜0~1時: feed 5 + story 10 = 15コ

      heatmap = Heatmap.new(@brand, aggregated_from: "2021/02/01", aggregated_to: "2021/02/02")
      expect(heatmap.max_post_count_per_hour).to eq 10 # 期間外の10投稿はカウントされないため2の10コが最大値
    end
  end
end
