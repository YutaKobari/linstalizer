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
  end

  describe "brandlift_per_dateのテスト" do
    before do
      FactoryBot.create(:brand_lift_value, date: @today - 2.days, value: 300)
      FactoryBot.create(:brand_lift_value, date: @today - 1.days, value: 200)
      FactoryBot.create(:brand_lift_value, date: @today,          value: 100)
    end
    example "日付とブランドリフトのペアが正常に返ってくる" do
      brandlift_data = @brand.brandlift_per_date("#{@today.year}-#{@today.month}", 2)
      expect(brandlift_data.size).to eq @today.day # 日数分のデータが返ってくる
      existing_brandlift_data = brandlift_data.reject{ |d| d[:none] == true }
      expect(existing_brandlift_data.size).to eq 3
      expect(existing_brandlift_data[0]).to eq ({date: (@today - 2.days).to_s, value: 300, none: nil})
      expect(existing_brandlift_data[1]).to eq ({date: (@today - 1.days).to_s, value: 200, none: nil})
      expect(existing_brandlift_data[2]).to eq ({date: @today.to_s,            value: 100, none: nil})
    end
    example "ブランドIDが一致しないものはカウントされない" do
      FactoryBot.create(:brand_lift_value, brand_id: 2)
      brandlift_data = @brand.brandlift_per_date("#{@today.year}-#{@today.month}", 2)
      existing_brandlift_data = brandlift_data.reject{ |d| d[:none] == true }
      expect(existing_brandlift_data.size).to eq 3
    end
    example "指定された期間外のものはカウントされない" do
      FactoryBot.create(:brand_lift_value, date: (@today - 1.year))
      brandlift_data = @brand.brandlift_per_date("#{@today.year-1}-#{@today.month}", 2)
      existing_brandlift_data = brandlift_data.reject{ |d| d[:none] == true }
      expect(existing_brandlift_data.size).to eq 1
    end
  end

  describe "posts_per_dateのテスト" do
    before do
      FactoryBot.create(:post, posted_on: @today, media: "LINE")
      FactoryBot.create(:post, posted_on: @today, media: "Twitter")
      FactoryBot.create(:post, posted_on: @today - 1.days, media: "LINE")
    end
    example "投稿日とメディアでグループ化された投稿数の合計が返ってくる" do
      posts_data = JSON.parse(@brand.posts_per_date("#{@today.year}-#{@today.month}"))
      expect(posts_data).to include({"media" => "LINE", "posted_on" => (@today - 1.days).strftime, "sum" => 1})
      expect(posts_data).to include({"media" => "LINE", "posted_on" => @today.strftime, "sum" => 1})
      expect(posts_data).to include({"media" => "Twitter", "posted_on" => @today.strftime, "sum" => 1})
    end
    example "投稿日、メディアが同じ投稿が複数あると投稿数の合計に加算される" do
      FactoryBot.create(:post, posted_on: @today, media: "Instagram")
      FactoryBot.create(:post, posted_on: @today, media: "Instagram")
      FactoryBot.create(:post, posted_on: @today, media: "Instagram")
      posts_data = JSON.parse(@brand.posts_per_date("#{@today.year}-#{@today.month}"))
      expect(posts_data).to include({"media" => "Instagram", "posted_on" => @today.strftime, "sum" => 3})
    end
    example "ブランドIDが一致しないものはカウントされない" do
      FactoryBot.create(:post, posted_on: @today, media: "Facebook", brand_id: 2)
      posts_data = JSON.parse(@brand.posts_per_date("#{@today.year}-#{@today.month}"))
      expect(posts_data).not_to include({"media" => "Facebook", "posted_on" => @today.strftime, "sum" => 1})
    end
  end

  describe "talk_posts_per_dateのテスト" do
    before do
      FactoryBot.create(:talk_post, posted_on: @today - 1.days)
      FactoryBot.create(:talk_post, posted_on: @today)
    end
    example "投稿日でグループ化された投稿数の合計が返ってくる" do # mediaは一律LINE
      talk_posts_data = JSON.parse(@brand.talk_posts_per_date("#{@today.year}-#{@today.month}"))
      expect(talk_posts_data).to include({"media" => "LINE", "posted_on" => (@today - 1.days).strftime, "sum" => 1})
      expect(talk_posts_data).to include({"media" => "LINE", "posted_on" => @today.strftime, "sum" => 1})
    end
    example "同じ投稿日の投稿が複数あると投稿数の合計に加算される" do
      FactoryBot.create(:talk_post, posted_on: @today - 2.days)
      FactoryBot.create(:talk_post, posted_on: @today - 2.days)
      FactoryBot.create(:talk_post, posted_on: @today - 2.days)
      talk_posts_data = JSON.parse(@brand.talk_posts_per_date("#{@today.year}-#{@today.month}"))
      expect(talk_posts_data).to include({"media" => "LINE", "posted_on" => (@today - 2.days).strftime, "sum" => 3})
    end
    example "ブランドIDが一致しないものはカウントされない" do
      FactoryBot.create(:talk_post, posted_on: @today - 3.days, brand_id: 2)
      posts_data = JSON.parse(@brand.talk_posts_per_date("#{@today.year}-#{@today.month}"))
      expect(posts_data).not_to include({"media" => "LINE", "posted_on" => (@today - 3.days).strftime, "sum" => 1})
    end
  end
end
