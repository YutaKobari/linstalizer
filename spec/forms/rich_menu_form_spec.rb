require 'rails_helper'

RSpec.describe RichMenuForm, type: :model do
  before do
    FactoryBot.create(:company)
    FactoryBot.create(:market)
    FactoryBot.create(:brand)
    @current_account = FactoryBot.create(:account)
    FactoryBot.create(:landing_page)
    FactoryBot.create(:lp_combined_url)
  end

  it '並び替えが表示開始日の新しい順あるいは空白でなければ無効である' do
    valid_form1 = RichMenuForm.new(sort: 'date_from')
    valid_form2 = RichMenuForm.new(sort: '')
    invalid_form = RichMenuForm.new(sort: 'invalid sort type')
    expect(valid_form1.valid?).to eq true
    expect(valid_form2.valid?).to eq true
    expect(invalid_form.valid?).to eq false
  end

  describe 'searchメソッドのテスト' do
    context '条件を何も指定しない' do
      example 'すべてのレコードが返ってくる' do
        8.times { FactoryBot.create(:rich_menu) }
        result = RichMenuForm.new.search
        expect(result.length).to eq 8
      end
    end
    context 'アカウント名で検索する' do
      example 'アカウント名にマッチしたアカウントに紐づくメニューが返ってくる' do
        FactoryBot.create(:account, name: 'ヒットするアカウント') do |account|
          @hit = FactoryBot.create(:rich_menu, account_id: account.id)
        end
        2.times { FactoryBot.create(:rich_menu) }
        result = RichMenuForm.new(search_account: 'ヒット').search
        expect(result.length).to eq 1
        expect(result.first).to eq @hit
      end
    end
    context 'LPのURLで検索する' do
      example '検索したURLとマッチしたLPに紐づくメニューが返ってくる' do
        FactoryBot.create(:landing_page) do |lp|
          FactoryBot.create(:lp_combined_url, url_hash: lp.url_hash, combined_url: 'http://localhost:3000#ヒット')
          @hit = FactoryBot.create(:rich_menu) do |rich_menu|
            FactoryBot.create(:rich_menu_content, url_hash: lp.url_hash, group_hash: rich_menu.group_hash)
          end
        end
        2.times { FactoryBot.create(:rich_menu) }
        result = RichMenuForm.new(search_url: 'ヒット').search
        expect(result.length).to eq 1
        expect(result.first).to eq @hit
      end
    end

    # 絞り込み方法の変更に応じてテストも変更する
    context '表示開始日で絞り込みする' do
      example '表示開始日が指定された期間内のメニューが返ってくる' do
        2.times { FactoryBot.create(:rich_menu, date_from: '2021/03/01'.to_date) }
        FactoryBot.create(:rich_menu, date_from: '2021/01/01'.to_date)
        result = RichMenuForm.new(start_date: '2021/02/01'.to_date, end_date: '2021/03/01'.to_date).search
        expect(result.length).to eq 2
        expect(result.first.date_from).to eq '2021/03/01'.to_date
      end
    end

    # 並び替え方法の変更に応じてテストも変更する
    context '並び替えを行う' do
      before do
        FactoryBot.create(:rich_menu, date_from: '2021/02/01'.to_date)
        FactoryBot.create(:rich_menu, date_from: '2021/02/02'.to_date)
        FactoryBot.create(:rich_menu, date_from: '2021/02/03'.to_date)
      end
      context '何も指定しない' do
        example '表示開始日が新しい順に表示される' do
          result = RichMenuForm.new(sort: '').search
          expect(result.length).to eq 3
          expect(result.first.date_from).to eq '2021/02/03'.to_date
          expect(result.second.date_from).to eq '2021/02/02'.to_date
          expect(result.third.date_from).to eq '2021/02/01'.to_date
        end
      end
      context '表示開始日が新しい順' do
        example '表示開始日が新しい順に表示される' do
          result = RichMenuForm.new(sort: 'date_from').search
          expect(result.length).to eq 3
          expect(result.first.date_from).to eq '2021/02/03'.to_date
          expect(result.second.date_from).to eq '2021/02/02'.to_date
          expect(result.third.date_from).to eq '2021/02/01'.to_date
        end
      end
    end
  end

  describe 'search_in_accounts_showメソッドのテスト' do
    before do
      @other_account = FactoryBot.create(:account)
    end
    context '条件を何も指定しない' do
      example '対象アカウントのすべてのレコードが返ってくる' do
        8.times { FactoryBot.create(:rich_menu) }
        FactoryBot.create(:rich_menu, account_id: @other_account.id)
        result = RichMenuForm.new.search_in_accounts_show(@current_account.id)
        expect(result.length).to eq 8
      end
    end
    context 'LPのURLで検索する' do
      example '検索したURLとマッチしたLPに紐づく該当アカウントのメニューが返ってくる' do
        FactoryBot.create(:landing_page) do |lp|
          FactoryBot.create(:lp_combined_url, url_hash: lp.url_hash, combined_url: 'http://localhost:3000#ヒット')
          @hit = FactoryBot.create(:rich_menu) do |rich_menu|
            FactoryBot.create(:rich_menu_content, url_hash: lp.url_hash, group_hash: rich_menu.group_hash)
          end
          # ワードはヒットするが別アカウントのリッチメニュー
          FactoryBot.create(:rich_menu, account_id: @other_account.id) do |rich_menu|
            FactoryBot.create(:rich_menu_content, url_hash: lp.url_hash, group_hash: rich_menu.group_hash)
          end
        end
        2.times { FactoryBot.create(:rich_menu) }
        result = RichMenuForm.new(search_url: 'ヒット').search_in_accounts_show(@current_account.id)
        expect(result.length).to eq 1
        expect(result.first).to eq @hit
      end
    end

    # 絞り込み方法の変更に応じてテストも変更する
    context '表示開始日で絞り込みする' do
      example '表示開始日が指定された期間内の対象アカウントのメニューが返ってくる' do
        2.times { FactoryBot.create(:rich_menu, date_from: '2021/03/01'.to_date) }
        FactoryBot.create(:rich_menu, date_from: '2021/01/01'.to_date)
        # 期間内だが別アカウントのリッチメニュー
        FactoryBot.create(:rich_menu, date_from: '2021/03/01'.to_date, account_id: @other_account.id)
        result = RichMenuForm.new(start_date: '2021/02/01'.to_date, end_date: '2021/03/01'.to_date).search_in_accounts_show(@current_account.id)
        expect(result.length).to eq 2
        expect(result.first.date_from).to eq '2021/03/01'.to_date
      end
    end

    # 並び替え方法の変更に応じてテストも変更する
    context '並び替えを行う' do
      before do
        FactoryBot.create(:rich_menu, date_from: '2021/02/01'.to_date)
        FactoryBot.create(:rich_menu, date_from: '2021/02/02'.to_date)
        FactoryBot.create(:rich_menu, date_from: '2021/02/03'.to_date)
      end
      context '何も指定しない' do
        example '表示開始日が新しい順に表示される' do
          result = RichMenuForm.new(sort: '').search
          expect(result.length).to eq 3
          expect(result.first.date_from).to eq '2021/02/03'.to_date
          expect(result.second.date_from).to eq '2021/02/02'.to_date
          expect(result.third.date_from).to eq '2021/02/01'.to_date
        end
      end
      context '表示開始日が新しい順' do
        example '表示開始日が新しい順に表示される' do
          result = RichMenuForm.new(sort: 'date_from').search
          expect(result.length).to eq 3
          expect(result.first.date_from).to eq '2021/02/03'.to_date
          expect(result.second.date_from).to eq '2021/02/02'.to_date
          expect(result.third.date_from).to eq '2021/02/01'.to_date
        end
      end
    end
  end
end
