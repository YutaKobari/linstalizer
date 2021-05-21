require 'rails_helper'

RSpec.describe AccountForm, :type => :model do
  before do
    FactoryBot.create(:company)
    FactoryBot.create(:market)
    FactoryBot.create(:brand)
    @account1 = FactoryBot.create(:account)
  end

  it "SNSがLINE,Instagram以外であれば無効である" do
    account_form = AccountForm.new(media: "hoge_media")
    expect(account_form.valid?).to eq false

    valid_media = %w(LINE Instagram)
    valid_media.each do |valid_media|
      account_form = AccountForm.new(media: valid_media)
      expect(account_form.valid?).to eq true
    end
  end

  it "並び替えがfollower_increment,post_increment,follower_increment_rate,total_reaction_increment_rate以外であれば無効である" do
    account_form = AccountForm.new(sort: "hoge_sort")
    expect(account_form.valid?).to eq false

    valid_sorts = %w(follower_increment post_increment follower_increment_rate total_reaction_increment_rate)
    valid_sorts.each do |valid_sort|
      account_form = AccountForm.new(sort: valid_sort)
      expect(account_form.valid?).to eq true
    end
  end
end
