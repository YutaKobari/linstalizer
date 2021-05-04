require 'rails_helper'

RSpec.describe TalkPostForm, type: :model do
  before do
    FactoryBot.create(:company)
    FactoryBot.create(:market)
    FactoryBot.create(:brand)
    FactoryBot.create(:account)
    FactoryBot.create(:account, name: 'アカウント2')
    FactoryBot.create(:landing_page)
    @talk_post1 = FactoryBot.create(:talk_post, talk_group_hash: 'test_hash')
    @talk_post_content1 = FactoryBot.create(:talk_post_content, talk_group_hash: 'test_hash')
  end

  # TODO: 項目の追加
  it '投稿タイプのバリデーション' do
    post = TalkPostForm.new(post_type: 'hoge_post_type')
    expect(post.valid?).to eq false

    valid_post_types = %w[text image video image_map carousel]
    valid_post_types.each do |valid_post_type|
      post = TalkPostForm.new(post_type: valid_post_type)
      expect(post.valid?).to eq true
    end
  end

  describe 'searchメソッドのテスト' do
    context '条件を何も指定しない' do
      before do
        9.times { |_n| FactoryBot.create(:talk_post, talk_group_hash: "test_group_hash#{_n}") }
        9.times { |_n| FactoryBot.create(:talk_post_content, talk_group_hash: "test_group_hash#{_n}") }
        @post_form = TalkPostForm.new
      end
      example '全てのレコードが返ってくる' do
        posts = @post_form.search
        expect(posts.length).to eq 10
      end
    end

    context 'キーワードで検索する' do
      before do
        FactoryBot.create(:talk_post_content, text: 'テスト文字列', talk_group_hash: @talk_post1.talk_group_hash)
        FactoryBot.create(:talk_post_content, text: 'テスト文字列', talk_group_hash: @talk_post1.talk_group_hash)
        talk_post2 = FactoryBot.create(:talk_post)
        FactoryBot.create(:talk_post_content, text: '文字列', talk_group_hash: talk_post2.talk_group_hash)
        @post_form = TalkPostForm.new(search_text: 'テスト')
      end
      example 'textにキーワードが含まれるレコードが返ってくる' do
        posts = @post_form.search
        expect(posts.length).to eq 1
      end
    end

    context 'アカウント名で検索する' do
      before do
        FactoryBot.create(:talk_post, account_id: 2, talk_group_hash: 'test_hash2')
        FactoryBot.create(:talk_post_content, account_id: 2, talk_group_hash: 'test_hash2')
        @post_form = TalkPostForm.new(search_account: 'アカウント2')
      end
      example 'アカウント名にマッチしたアカウントに紐づく投稿が返ってくる' do
        posts = @post_form.search
        expect(posts.length).to eq 1
        expect(posts.first.account_id).to eq 2
      end
    end

    context 'LPのURLで検索' do
      before do
        @post_form = TalkPostForm.new(search_url: 'http://example.com/')
        talk_post2 = FactoryBot.create(:talk_post)
        FactoryBot.create(:talk_post_content, talk_group_hash: talk_post2.talk_group_hash) do |content|
          FactoryBot.create(:landing_page, url_hash: content.url_hash)
          FactoryBot.create(:lp_combined_url, url_hash: content.url_hash)
        end
      end
      example '検索したURLとマッチしたLPに紐づく投稿が返ってくる' do
        posts = @post_form.search
        expect(posts.length).to eq 1
      end
    end

    describe '投稿タイプで検索' do
      context '存在する投稿タイプで検索' do
        before do
          @post_form = TalkPostForm.new(post_type: 'image')
          talk_post2 = FactoryBot.create(:talk_post)
          talk_post3 = FactoryBot.create(:talk_post)
          FactoryBot.create(:talk_post_content, post_type: 'text', talk_group_hash: @talk_post1.talk_group_hash)
          FactoryBot.create(:talk_post_content, post_type: 'image', talk_group_hash: @talk_post1.talk_group_hash)
          FactoryBot.create(:talk_post_content, post_type: 'text', talk_group_hash: talk_post2.talk_group_hash)
          FactoryBot.create(:talk_post_content, post_type: 'image', talk_group_hash: talk_post2.talk_group_hash)
          FactoryBot.create(:talk_post_content, post_type: 'text', talk_group_hash: talk_post3.talk_group_hash)
          FactoryBot.create(:talk_post_content, post_type: 'video', talk_group_hash: talk_post3.talk_group_hash)
        end
        example '検索した投稿タイプと一致する投稿が返ってくる' do
          posts = @post_form.search
          expect(posts.length).to eq 2
        end
      end

      context '存在しない投稿タイプで検索' do
        before do
          @post_form = TalkPostForm.new(post_type: 'hoge_post_type')
          FactoryBot.create(:talk_post)
        end
        example '一つもレコードが返ってこない' do
          posts = @post_form.search
          expect(posts.length).to eq 0
        end
      end
    end

    context '投稿日で絞り込む' do
      before do
        # TalkPostFormのstarted_atはデフォルトで2021/02/01
        @post_form = TalkPostForm.new(end_date: '2021/02/28'.to_date)
        FactoryBot.create(:talk_post, posted_at: '2021/03/01 10:00 JTC'.to_time)
      end
      example '投稿日が指定された期間内の投稿が返ってくる' do
        posts = @post_form.search
        expect(posts.length).to eq 1
        expect(I18n.l(posts.first.posted_at, format: :long)).to eq '2021/02/01 (月) 10:00'
      end
    end

    describe '並び替え' do
      before do
        TalkPost.destroy_all
        FactoryBot.create(:talk_post) do |talk_post|
          FactoryBot.create(:talk_post_content, posted_at: '2021/02/02 00:00 JTC'.to_time,
                                                talk_group_hash: talk_post.talk_group_hash)
        end
        FactoryBot.create(:talk_post) do |talk_post|
          FactoryBot.create(:talk_post_content, posted_at: '2021/02/01 23:59 JTC'.to_time,
                                                talk_group_hash: talk_post.talk_group_hash)
        end
        FactoryBot.create(:talk_post) do |talk_post|
          FactoryBot.create(:talk_post_content, posted_at: '2021/02/02 00:01 JTC'.to_time,
                                                talk_group_hash: talk_post.talk_group_hash)
        end
        @post_form = TalkPostForm.new(end_date: '2021/02/03'.to_date)
      end
      example '標準で投稿日時が新しい順に表示される' do
        posts = @post_form.search
        expect(I18n.l(posts.first.posted_at, format: :long)).to eq '2021/02/02 (火) 00:01'
        expect(I18n.l(posts.second.posted_at, format: :long)).to eq '2021/02/02 (火) 00:00'
        expect(I18n.l(posts.third.posted_at, format: :long)).to eq '2021/02/01 (月) 23:59'
      end
    end
  end

  describe 'search_in_accounts_showメソッドのテスト' do
    before do
      @current_account = FactoryBot.create(:account)
      @other_account = FactoryBot.create(:account)
    end
    context '条件を何も指定しない' do
      before do
        9.times { |n| FactoryBot.create(:talk_post, talk_group_hash: "test_group_hash#{n}") }
        9.times { |n| FactoryBot.create(:talk_post_content, talk_group_hash: "test_group_hash#{n}") }
        FactoryBot.create(:talk_post, account_id: @current_account.id) do |talk_post|
          FactoryBot.create(:talk_post_content, talk_group_hash: talk_post.talk_group_hash,
                                                account_id: @current_account.id)
        end
        @post_form = TalkPostForm.new
      end
      example '該当アカウントの全てのレコードが返ってくる' do
        posts = @post_form.search_in_accounts_show(@current_account.id)
        expect(posts.length).to eq 1
      end
    end

    context 'キーワードで検索する' do
      before do
        FactoryBot.create(:talk_post) do |talk_post|
          FactoryBot.create(:talk_post_content, text: 'テスト文字列', talk_group_hash: talk_post.talk_group_hash,
                                                account_id: @current_account.id)
          FactoryBot.create(:talk_post_content, text: 'テスト文字列', talk_group_hash: talk_post.talk_group_hash,
                                                account_id: @current_account.id)
        end
        FactoryBot.create(:talk_post, account_id: @other_account.id) do |talk_post|
          FactoryBot.create(:talk_post_content, text: 'テスト文字列', talk_group_hash: talk_post.talk_group_hash,
                                                account_id: @other_account.id)
          FactoryBot.create(:talk_post_content, text: 'テスト文字列', talk_group_hash: talk_post.talk_group_hash,
                                                account_id: @other_account.id)
        end
        FactoryBot.create(:talk_post, account_id: @current_account.id) do |talk_post|
          FactoryBot.create(:talk_post_content, text: '文字列', talk_group_hash: talk_post.talk_group_hash,
                                                account_id: @current_account.id)
        end
        @post_form = TalkPostForm.new(search_text: 'テスト')
      end
      example '該当アカウントでtextにキーワードが含まれるレコードが返ってくる' do
        posts = @post_form.search_in_accounts_show(@current_account.id)
        expect(posts.length).to eq 1
      end
    end

    context 'LPのURLで検索' do
      before do
        @post_form = TalkPostForm.new(search_url: 'http://example.com/')
        FactoryBot.create(:landing_page) do |lp|
          FactoryBot.create(:lp_combined_url, url_hash: lp.url_hash)
          FactoryBot.create(:talk_post, account_id: @current_account.id) do |talk_post|
            FactoryBot.create(:talk_post_content, talk_group_hash: talk_post.talk_group_hash,
                                                  account_id: @current_account.id, url_hash: lp.url_hash)
          end
          FactoryBot.create(:talk_post, account_id: @other_account.id) do |talk_post|
            FactoryBot.create(:talk_post_content, talk_group_hash: talk_post.talk_group_hash,
                                                  account_id: @other_account.id, url_hash: lp.url_hash)
          end
        end
        FactoryBot.create(:talk_post, account_id: @current_account.id) do |talk_post|
          FactoryBot.create(:talk_post_content, talk_group_hash: talk_post.talk_group_hash,
                                                account_id: @current_account.id)
        end
      end
      example '該当アカウントで検索したURLとマッチしたLPに紐づく投稿が返ってくる' do
        posts = @post_form.search_in_accounts_show(@current_account.id)
        expect(posts.length).to eq 1
      end
    end

    context '存在する投稿タイプで検索' do
      before do
        @post_form = TalkPostForm.new(post_type: 'image')
        #アカウント一致 text,image
        FactoryBot.create(:talk_post, account_id: @current_account.id) do |talk_post|
          FactoryBot.create(:talk_post_content, post_type: 'text', talk_group_hash: talk_post.talk_group_hash, account_id: @current_account.id)
          FactoryBot.create(:talk_post_content, post_type: 'image', talk_group_hash: talk_post.talk_group_hash, account_id: @current_account.id)
        end
        #アカウント不一致 text,image
        FactoryBot.create(:talk_post, account_id: @other_account.id) do |talk_post|
          FactoryBot.create(:talk_post_content, post_type: 'text', talk_group_hash: talk_post.talk_group_hash, account_id: @other_account.id)
          FactoryBot.create(:talk_post_content, post_type: 'image', talk_group_hash: talk_post.talk_group_hash, account_id: @other_account.id)
        end
        # アカウント一致 image,video
        FactoryBot.create(:talk_post, account_id: @current_account.id) do |talk_post|
          FactoryBot.create(:talk_post_content, post_type: 'image', talk_group_hash: talk_post.talk_group_hash, account_id: @current_account.id)
          FactoryBot.create(:talk_post_content, post_type: 'video', talk_group_hash: talk_post.talk_group_hash, account_id: @current_account.id)
        end
      end
      example '検索した投稿タイプと一致する投稿が返ってくる' do
        posts = @post_form.search_in_accounts_show(@current_account.id)
        expect(posts.length).to eq 2
      end
    end

    context '投稿日で絞り込む' do
      before do
        # TalkPostFormのstarted_atはデフォルトで2021/02/01
        @post_form = TalkPostForm.new(end_date: '2021/02/28'.to_date)
        FactoryBot.create(:talk_post, posted_at: '2021/03/01 10:00 JTC'.to_time, account_id: @current_account.id) do |talk_post|
          FactoryBot.create(:talk_post_content, talk_group_hash: talk_post.talk_group_hash, account_id: @current_account.id)
        end
        FactoryBot.create(:talk_post, posted_at: '2021/03/01 10:00 JTC'.to_time, account_id: @other_account.id) do |talk_post|
          FactoryBot.create(:talk_post_content, talk_group_hash: talk_post.talk_group_hash, account_id: @other_account.id)
        end
      end
      example '投稿日が指定された期間内の投稿が返ってくる' do
        posts = @post_form.search_in_accounts_show(@current_account.id)
        expect(posts.length).to eq 1
        expect(I18n.l(posts.first.posted_at, format: :long)).to eq '2021/02/01 (月) 10:00'
      end
    end
  end
end
