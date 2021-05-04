require 'rails_helper'

RSpec.describe HashTagForm, type: :model do
  before do
    FactoryBot.create(:company)
    FactoryBot.create(:market)
    FactoryBot.create(:brand)
    FactoryBot.create(:account)
    FactoryBot.create(:post)
    FactoryBot.create(:hash_tag)
    FactoryBot.create(:post_hash_tag)
  end

  it "並び替えがpost_increment,total_reaction_increment以外であれば無効である" do
    hash_tag_form = HashTagForm.new(sort: "hoge_sort")
    expect(hash_tag_form.valid?).to eq false

    valid_sorts = %w(post_increment total_reaction_increment)
    valid_sorts.each do |valid_sort|
      hash_tag_form = HashTagForm.new(sort: valid_sort)
      expect(hash_tag_form.valid?).to eq true
    end
  end
end
