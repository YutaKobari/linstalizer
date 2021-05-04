require 'rails_helper'

RSpec.describe PostForm, type: :model do
  before do
    FactoryBot.create(:company)
    FactoryBot.create(:market)
    FactoryBot.create(:brand)
    FactoryBot.create(:account)
    FactoryBot.create(:account, name: 'アカウント2')
    FactoryBot.create(:landing_page)
    FactoryBot.create(:post)
  end

  it 'メディアがLINE,Instagram,Twitter,Facebook以外であれば無効である' do
    post = PostForm.new(media: 'hoge_media')
    expect(post.valid?).to eq false

    valid_media = %w[LINE Instagram Twitter Facebook]
    valid_media.each do |valid_media|
      post = PostForm.new(media: valid_media)
      expect(post.valid?).to eq true
    end
  end

  it '投稿タイプがfeed,reel,story,tweet,retweet,normal_post以外であれば無効である' do
    post = PostForm.new(post_type: 'hoge_post_type')
    expect(post.valid?).to eq false

    valid_post_types = %w[feed reel story tweet retweet normal_post]
    valid_post_types.each do |valid_post_type|
      post = PostForm.new(post_type: valid_post_type)
      expect(post.valid?).to eq true
    end
  end

  it '並び替えがlike,retweet以外であれば無効である' do
    post = PostForm.new(sort: 'hoge_sort')
    expect(post.valid?).to eq false

    valid_sorts = %w[like retweet]
    valid_sorts.each do |valid_sort|
      post = PostForm.new(sort: valid_sort)
      expect(post.valid?).to eq true
    end
  end

  describe 'searchメソッドのテスト' do
    context '条件を何も指定しない' do
      before do
        9.times { FactoryBot.create(:post) }
        @post_form = PostForm.new
      end
      example '全てのレコードが返ってくる' do
        posts = @post_form.search
        expect(posts.size).to eq 10
      end
    end

    context 'キーワードで検索する' do
      before do
        FactoryBot.create(:post, text: 'テスト文字列')
        @post_form = PostForm.new(search_text: 'テスト')
      end
      example 'textにキーワードが含まれる投稿が返ってくる' do
        posts = @post_form.search
        expect(posts.size).to eq 1
        expect(posts.first.text).to include 'テスト'
      end
    end

    context 'アカウント名で検索する' do
      before do
        FactoryBot.create(:post, account_id: 2)
        @post_form = PostForm.new(search_account: 'アカウント2')
      end
      example 'アカウント名にマッチしたアカウントに紐づく投稿が返ってくる' do
        posts = @post_form.search
        expect(posts.size).to eq 1
        expect(posts.first.account_id).to eq 2
      end
    end

    context 'ハッシュタグで検索する' do
      before do
        @post_form = PostForm.new(search_hash_tag: 'ハッシュタグ1')
        FactoryBot.create(:hash_tag)
        FactoryBot.create(:post) do |post|
          FactoryBot.create(:post_hash_tag, post_id: post.id)
        end
      end
      example 'ハッシュタグに紐づく投稿が返ってくる' do
        posts = @post_form.search
        expect(posts.size).to eq 1
        expect(posts.first.hash_tags.first.name).to eq 'ハッシュタグ1'
      end
    end

    context 'LPのURLで検索' do
      before do
        @post_form = PostForm.new(search_url: 'http://example.com/')
        FactoryBot.create(:post, url_hash: 'url_hash') do |post|
          FactoryBot.create(:landing_page, url_hash: post.url_hash)
          FactoryBot.create(:lp_combined_url, url_hash: post.url_hash)
        end
      end
      example '検索したURLとマッチしたLPに紐づく投稿が返ってくる' do
        posts = @post_form.search
        expect(posts.size).to eq 1
      end
    end

    describe 'メディアで検索' do
      context '存在するメディアで検索' do
        before do
          @post_form = PostForm.new(media: 'LINE')
          FactoryBot.create(:post, media: 'LINE')
        end
        example 'メディアが一致する投稿が返ってくる' do
          posts = @post_form.search
          expect(posts.size).to eq 1
          expect(posts.first.media).to eq 'LINE'
        end
      end

      context '存在しないメディアで検索' do
        before do
          @post_form = PostForm.new(media: 'hogemedia')
          FactoryBot.create(:post, media: 'Instagram')
        end
        example '一つもレコードが返ってこない' do
          posts = @post_form.search
          expect(posts.size).to eq 0
        end
      end
    end

    describe '投稿タイプで検索' do
      context '存在する投稿タイプで検索' do
        before do
          @post_form = PostForm.new(post_type: 'feed')
        end
        example '検索した投稿タイプと一致する投稿が返ってくる' do
          posts = @post_form.search
          expect(posts.size).to eq 1
          expect(posts.first.post_type).to eq 'feed'
        end
      end

      context '存在しない投稿タイプで検索' do
        before do
          @post_form = PostForm.new(post_type: 'hoge_post_type')
          FactoryBot.create(:post)
        end
        example '一つもレコードが返ってこない' do
          posts = @post_form.search
          expect(posts.size).to eq 0
        end
      end
    end

    context '投稿日で絞り込む' do
      before do
        # PostFormのstarted_atはデフォルトで2021/02/01
        @post_form = PostForm.new(end_date: '2021/02/28'.to_date)
        FactoryBot.create(:post, posted_at: '2021/03/01 10:00 JTC'.to_time)
      end
      example '投稿日が指定された期間内の投稿が返ってくる' do
        posts = @post_form.search
        expect(posts.size).to eq 1
        expect(I18n.l(posts.first.posted_at, format: :long)).to eq '2021/02/01 (月) 10:00'
      end
    end

    describe '並び替え' do
      before do
        Post.destroy_all
        FactoryBot.create(:post, like_count: 1, retweet_count: 3, posted_at: '2021/02/02 12:30 JTC'.to_time)
        FactoryBot.create(:post, like_count: 2, retweet_count: 2, posted_at: '2021/02/02 12:29 JTC'.to_time)
        FactoryBot.create(:post, like_count: 3, retweet_count: 1, posted_at: '2021/02/03 07:05 JTC'.to_time)
      end

      context 'いいね数で並び替え' do
        before { @post_form = PostForm.new(sort: 'like', end_date: '2021/02/04'.to_date) }
        example 'いいね数が多い順に表示される' do
          posts = @post_form.search
          expect(posts.first.like_count).to  eq 3
          expect(posts.second.like_count).to eq 2
          expect(posts.third.like_count).to  eq 1
        end
      end

      context 'リツイート数で並び替え' do
        before { @post_form = PostForm.new(sort: 'retweet', end_date: '2021/02/04'.to_date) }
        example 'リツイート数が多い順に表示される' do
          posts = @post_form.search
          expect(posts.first.retweet_count).to  eq 3
          expect(posts.second.retweet_count).to eq 2
          expect(posts.third.retweet_count).to  eq 1
        end
      end

      context '投稿が新しい順で並び替え' do
        before { @post_form = PostForm.new(sort: 'posted_at', end_date: '2021/02/04'.to_date) }
        example '投稿日時が新しい順に表示される' do
          posts = @post_form.search
          expect(I18n.l(posts.first.posted_at, format: :long)).to eq '2021/02/03 (水) 07:05'
          expect(I18n.l(posts.second.posted_at, format: :long)).to eq '2021/02/02 (火) 12:30'
          expect(I18n.l(posts.third.posted_at, format: :long)).to eq '2021/02/02 (火) 12:29'
        end
      end

      context '何も指定しない' do
        before { @post_form = PostForm.new(end_date: '2021/02/04'.to_date) }
        example '投稿日時が新しい順に表示される' do
          posts = @post_form.search
          expect(I18n.l(posts.first.posted_at, format: :long)).to eq '2021/02/03 (水) 07:05'
          expect(I18n.l(posts.second.posted_at, format: :long)).to eq '2021/02/02 (火) 12:30'
          expect(I18n.l(posts.third.posted_at, format: :long)).to eq '2021/02/02 (火) 12:29'
        end
      end

      context '存在しない並び替え方法を指定する' do
        before { @post_form = PostForm.new(sort: 'hoge_sort', end_date: '2021/02/04'.to_date) }
        example '一つもレコードが返ってこない' do
          posts = @post_form.search
          expect(posts.size).to eq 0
        end
      end
    end
  end

  describe 'search_in_lp_showメソッドのテスト' do
    before do
      @current_lp = FactoryBot.create(:landing_page)
      @other_lp = FactoryBot.create(:landing_page)
    end
    context '条件を何も指定しない' do
      before do
        9.times { FactoryBot.create(:post, url_hash: @current_lp.url_hash) }
        2.times { FactoryBot.create(:post, url_hash: @other_lp.url_hash) }
        @post_form = PostForm.new
      end
      example '該当LPに到達する全てのレコードが返ってくる' do
        posts = @post_form.search_in_lp_show(@current_lp.id)
        expect(posts.size).to eq 9
      end
    end

    context 'キーワードで検索する' do
      before do
        FactoryBot.create(:post, text: 'テスト文字列', url_hash: @current_lp.url_hash)
        FactoryBot.create(:post, text: 'テスト文字列', url_hash: @other_lp.url_hash)
        FactoryBot.create(:post, text: 'ヒットしない文字列', url_hash: @current_lp.url_hash)
        @post_form = PostForm.new(search_text: 'テスト')
      end
      example '該当LPでtextにキーワードが含まれる投稿が返ってくる' do
        posts = @post_form.search_in_lp_show(@current_lp.id)
        expect(posts.size).to eq 1
        expect(posts.first.text).to include 'テスト'
      end
    end

    context 'ハッシュタグで検索する' do
      before do
        FactoryBot.create(:hash_tag)
        FactoryBot.create(:post, url_hash: @current_lp.url_hash) do |post| # 該当するハッシュタグ・該当するLP
          FactoryBot.create(:post_hash_tag, post_id: post.id)
        end
        FactoryBot.create(:post, url_hash: @other_lp.url_hash) do |post| # LP違い
          FactoryBot.create(:post_hash_tag, post_id: post.id)
        end
        FactoryBot.create(:post, url_hash: @current_lp.url_hash) # ハッシュタグ違い
        @post_form = PostForm.new(search_hash_tag: 'ハッシュタグ1')
      end
      example '該当LPでハッシュタグに紐づく投稿が返ってくる' do
        posts = @post_form.search_in_lp_show(@current_lp.id)
        expect(posts.size).to eq 1
        expect(posts.first.hash_tags.first.name).to eq 'ハッシュタグ1'
      end
    end

    context 'メディアで検索' do
      before do
        FactoryBot.create(:post, media: 'LINE', url_hash: @current_lp.url_hash)
        FactoryBot.create(:post, media: 'LINE', url_hash: @other_lp.url_hash)
        FactoryBot.create(:post, :feed)
        @post_form = PostForm.new(media: 'LINE')
      end
      example '該当LPでメディアが一致する投稿が返ってくる' do
        posts = @post_form.search_in_lp_show(@current_lp.id)
        expect(posts.size).to eq 1
        expect(posts.first.media).to eq 'LINE'
      end
    end

    context '投稿タイプで検索' do
      before do
        FactoryBot.create(:post, url_hash: @other_lp)
        FactoryBot.create(:post, :tweet, url_hash: @current_lp.url_hash)
        FactoryBot.create(:post, :feed, url_hash: @current_lp.url_hash)
        @post_form = PostForm.new(post_type: 'feed')
      end
      example '該当LPで検索した投稿タイプと一致する投稿が返ってくる' do
        posts = @post_form.search_in_lp_show(@current_lp.id)
        expect(posts.size).to eq 1
        expect(posts.first.post_type).to eq 'feed'
      end
    end

    context '投稿日で絞り込む' do
      before do
        # PostFormのstarted_atはデフォルトで2021/02/01
        @post_form = PostForm.new(end_date: '2021/02/28'.to_date)
        FactoryBot.create(:post, posted_at: '2021/03/01 10:00 JTC'.to_time, url_hash: @current_lp.url_hash)
        FactoryBot.create(:post, posted_at: '2021/02/01 10:00 JTC'.to_time, url_hash: @current_lp.url_hash)
        FactoryBot.create(:post, posted_at: '2021/02/02 10:00 JTC'.to_time, url_hash: @other_lp.id)
      end
      example '該当LPで投稿日が指定された期間内の投稿が返ってくる' do
        posts = @post_form.search_in_lp_show(@current_lp.id)
        expect(posts.size).to eq 1
        expect(I18n.l(posts.first.posted_at, format: :long)).to eq '2021/02/01 (月) 10:00'
      end
    end

    describe '並び替え' do
      before do
        Post.destroy_all
        FactoryBot.create(:post, like_count: 1, retweet_count: 3, posted_at: '2021/02/02 12:30 JTC'.to_time, url_hash: @current_lp.url_hash)
        FactoryBot.create(:post, like_count: 2, retweet_count: 2, posted_at: '2021/02/02 12:29 JTC'.to_time, url_hash: @current_lp.url_hash)
        FactoryBot.create(:post, like_count: 3, retweet_count: 1, posted_at: '2021/02/03 07:05 JTC'.to_time, url_hash: @current_lp.url_hash)
        FactoryBot.create(:post, like_count: 3, retweet_count: 3, posted_at: '2021/02/03 07:05 JTC'.to_time,
                                 url_hash: @other_lp.url_hash)
      end

      context 'いいね数で並び替え' do
        before { @post_form = PostForm.new(sort: 'like', end_date: '2021/02/04'.to_date) }
        example '該当LPでいいね数が多い順に表示される' do
          posts = @post_form.search_in_lp_show(@current_lp.id)
          expect(posts.first.like_count).to  eq 3
          expect(posts.second.like_count).to eq 2
          expect(posts.third.like_count).to  eq 1
        end
      end

      context 'リツイート数で並び替え' do
        before { @post_form = PostForm.new(sort: 'retweet', end_date: '2021/02/04'.to_date) }
        example '該当LPでリツイート数が多い順に表示される' do
          posts = @post_form.search_in_lp_show(@current_lp.id)
          expect(posts.first.retweet_count).to  eq 3
          expect(posts.second.retweet_count).to eq 2
          expect(posts.third.retweet_count).to  eq 1
        end
      end

      context '投稿が新しい順で並び替え' do
        before { @post_form = PostForm.new(sort: 'posted_at', end_date: '2021/02/04'.to_date) }
        example '該当LPで投稿日時が新しい順に表示される' do
          posts = @post_form.search_in_lp_show(@current_lp.id)
          expect(I18n.l(posts.first.posted_at, format: :long)).to eq '2021/02/03 (水) 07:05'
          expect(I18n.l(posts.second.posted_at, format: :long)).to eq '2021/02/02 (火) 12:30'
          expect(I18n.l(posts.third.posted_at, format: :long)).to eq '2021/02/02 (火) 12:29'
        end
      end

      context '何も指定しない' do
        before { @post_form = PostForm.new(end_date: '2021/02/04'.to_date) }
        example '該当LPで投稿日時が新しい順に表示される' do
          posts = @post_form.search_in_lp_show(@current_lp.id)
          expect(I18n.l(posts.first.posted_at, format: :long)).to eq '2021/02/03 (水) 07:05'
          expect(I18n.l(posts.second.posted_at, format: :long)).to eq '2021/02/02 (火) 12:30'
          expect(I18n.l(posts.third.posted_at, format: :long)).to eq '2021/02/02 (火) 12:29'
        end
      end

      context '存在しない並び替え方法を指定する' do
        before { @post_form = PostForm.new(sort: 'hoge_sort', end_date: '2021/02/04'.to_date) }
        example '一つもレコードが返ってこない' do
          pending '1つもレコードが返らないのが正しいのかすべて返すのが正しいのかわからないので'
          posts = @post_form.search_in_lp_show(@current_lp.id)
          expect(posts.size).to eq 0
        end
      end
    end
  end

  describe 'search_in_brands_showメソッドのテスト' do
    before do
      @current_brand = FactoryBot.create(:brand)
      @other_brand = FactoryBot.create(:brand)
    end
    context '条件を何も指定しない' do
      before do
        9.times { FactoryBot.create(:post, brand_id: @current_brand.id) }
        2.times { FactoryBot.create(:post, brand_id: @other_brand.id) }
        @post_form = PostForm.new
      end
      example '現在のブランドの全てのレコードが返ってくる' do
        posts = @post_form.search_in_brands_show(@current_brand.id)
        expect(posts.size).to eq 9
      end
    end
    context 'キーワードで検索する' do
      before do
        FactoryBot.create(:post, text: 'テスト文字列', brand_id: @current_brand.id)
        FactoryBot.create(:post, text: 'テスト文字列', brand_id: @other_brand.id)
        FactoryBot.create(:post, text: 'ヒットしない文字列', brand_id: @current_brand.id)
        @post_form = PostForm.new(search_text: 'テスト')
      end
      example '該当ブランドでtextにキーワードが含まれる投稿が返ってくる' do
        posts = @post_form.search_in_brands_show(@current_brand.id)
        expect(posts.size).to eq 1
        expect(posts.first.text).to include 'テスト'
      end
    end
    context 'ハッシュタグで検索する' do
      before do
        FactoryBot.create(:hash_tag)
        FactoryBot.create(:post, brand_id: @current_brand.id) do |post| # 該当するハッシュタグ・該当するブランド
          FactoryBot.create(:post_hash_tag, post_id: post.id)
        end
        FactoryBot.create(:post, brand_id: @other_brand.id) do |post| # ブランド違い
          FactoryBot.create(:post_hash_tag, post_id: post.id)
        end
        FactoryBot.create(:post, brand_id: @current_brand.id) # ハッシュタグ違い
        @post_form = PostForm.new(search_hash_tag: 'ハッシュタグ1')
      end
      example '該当ブランドでハッシュタグに紐づく投稿が返ってくる' do
        posts = @post_form.search_in_brands_show(@current_brand.id)
        expect(posts.size).to eq 1
        expect(posts.first.hash_tags.first.name).to eq 'ハッシュタグ1'
      end
    end
    context 'LPのURLで検索' do
      before do
        @post_form = PostForm.new(search_url: 'http://example.com/')
        FactoryBot.create(:landing_page) do |lp|
          FactoryBot.create(:lp_combined_url, url_hash: lp.url_hash) #ヒットするcombined_url
          FactoryBot.create(:post, url_hash: lp.url_hash, brand_id: @current_brand.id)
          FactoryBot.create(:post, url_hash: lp.url_hash, brand_id: @other_brand.id)
        end
        FactoryBot.create(:landing_page) do |lp|
          FactoryBot.create(:lp_combined_url, url_hash: lp.url_hash, combined_url: 'http://localhost:3000') #ヒットしないcombined_url
          FactoryBot.create(:post, url_hash: lp.url_hash, brand_id: @current_brand.id)
          FactoryBot.create(:post, url_hash: lp.url_hash, brand_id: @other_brand.id)
        end
      end
      example '該当ブランドで検索したURLとマッチしたLPに紐づく投稿が返ってくる' do
        posts = @post_form.search_in_brands_show(@current_brand.id)
        expect(posts.size).to eq 1
      end
    end
    context 'メディアで検索' do
      before do
        FactoryBot.create(:post, media: 'LINE', brand_id: @current_brand.id)
        FactoryBot.create(:post, media: 'LINE', brand_id: @other_brand.id)
        FactoryBot.create(:post, :feed, brand_id: @current_brand.id)
        @post_form = PostForm.new(media: 'LINE')
      end
      example '該当ブランドでメディアが一致する投稿が返ってくる' do
        posts = @post_form.search_in_brands_show(@current_brand.id)
        expect(posts.size).to eq 1
        expect(posts.first.media).to eq 'LINE'
      end
    end
    context '投稿日で絞り込む' do
      before do
        # PostFormのstarted_atはデフォルトで2021/02/01
        @post_form = PostForm.new(end_date: '2021/02/28'.to_date)
        FactoryBot.create(:post, posted_at: '2021/03/01 10:00 JTC'.to_time, brand_id: @current_brand.id)
        FactoryBot.create(:post, posted_at: '2021/02/01 10:00 JTC'.to_time, brand_id: @current_brand.id)
        FactoryBot.create(:post, posted_at: '2021/02/02 10:00 JTC'.to_time, brand_id: @other_brand.id)
      end
      example '該当ブランドで投稿日が指定された期間内の投稿が返ってくる' do
        posts = @post_form.search_in_brands_show(@current_brand.id)
        expect(posts.size).to eq 1
        expect(I18n.l(posts.first.posted_at, format: :long)).to eq '2021/02/01 (月) 10:00'
      end
    end
    context '投稿タイプで検索' do
      before do
        FactoryBot.create(:post, brand_id: @current_brand.id)
        FactoryBot.create(:post, :tweet, brand_id: @current_brand.id)
        FactoryBot.create(:post, :feed, brand_id: @other_brand.id)
        @post_form = PostForm.new(post_type: 'feed')
      end
      example '該当ブランドで検索した投稿タイプと一致する投稿が返ってくる' do
        posts = @post_form.search_in_brands_show(@current_brand.id)
        expect(posts.size).to eq 1
        expect(posts.first.post_type).to eq 'feed'
      end
    end

    describe '並び替え' do
      before do
        Post.destroy_all
        FactoryBot.create(:post, like_count: 1, retweet_count: 3, posted_at: '2021/02/02 12:30 JTC'.to_time, brand_id: @current_brand.id)
        FactoryBot.create(:post, like_count: 2, retweet_count: 2, posted_at: '2021/02/02 12:29 JTC'.to_time, brand_id: @current_brand.id)
        FactoryBot.create(:post, like_count: 3, retweet_count: 1, posted_at: '2021/02/03 07:05 JTC'.to_time, brand_id: @current_brand.id)
        FactoryBot.create(:post, like_count: 3, retweet_count: 3, posted_at: '2021/02/03 07:05 JTC'.to_time,
                                 brand_id: @other_brand.id)
      end
      context 'いいね数で並び替え' do
        before { @post_form = PostForm.new(sort: 'like', end_date: '2021/02/04'.to_date) }
        example '該当ブランドでいいね数が多い順に表示される' do
          posts = @post_form.search_in_brands_show(@current_brand.id)
          expect(posts.first.like_count).to  eq 3
          expect(posts.second.like_count).to eq 2
          expect(posts.third.like_count).to  eq 1
        end
      end
      context 'リツイート数で並び替え' do
        before { @post_form = PostForm.new(sort: 'retweet', end_date: '2021/02/04'.to_date) }
        example '該当ブランドでリツイート数が多い順に表示される' do
          posts = @post_form.search_in_brands_show(@current_brand.id)
          expect(posts.first.retweet_count).to  eq 3
          expect(posts.second.retweet_count).to eq 2
          expect(posts.third.retweet_count).to  eq 1
        end
      end
      context '投稿が新しい順で並び替え' do
        before { @post_form = PostForm.new(sort: 'posted_at', end_date: '2021/02/04'.to_date) }
        example '該当ブランドで投稿日時が新しい順に表示される' do
          posts = @post_form.search_in_brands_show(@current_brand.id)
          expect(I18n.l(posts.first.posted_at, format: :long)).to eq '2021/02/03 (水) 07:05'
          expect(I18n.l(posts.second.posted_at, format: :long)).to eq '2021/02/02 (火) 12:30'
          expect(I18n.l(posts.third.posted_at, format: :long)).to eq '2021/02/02 (火) 12:29'
        end
      end
      context '何も指定しない' do
        before { @post_form = PostForm.new(end_date: '2021/02/04'.to_date) }
        example '該当ブランドで投稿日時が新しい順に表示される' do
          posts = @post_form.search_in_brands_show(@current_brand.id)
          expect(I18n.l(posts.first.posted_at, format: :long)).to eq '2021/02/03 (水) 07:05'
          expect(I18n.l(posts.second.posted_at, format: :long)).to eq '2021/02/02 (火) 12:30'
          expect(I18n.l(posts.third.posted_at, format: :long)).to eq '2021/02/02 (火) 12:29'
        end
      end
      context '存在しない並び替え方法を指定する' do
        before { @post_form = PostForm.new(sort: 'hoge_sort', end_date: '2021/02/04'.to_date) }
        example '一つもレコードが返ってこない' do
          pending '1つもレコードが返らないのが正しいのかすべて返すのが正しいのかわからないので'
          posts = @post_form.search_in_brands_show(@current_brand.id)
          expect(posts.size).to eq 0
        end
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
        9.times { FactoryBot.create(:post, account_id: @current_account.id) }
        2.times { FactoryBot.create(:post, account_id: @other_account.id) }
        @post_form = PostForm.new
      end
      example '現在のアカウントの全てのレコードが返ってくる' do
        posts = @post_form.search_in_accounts_show(@current_account.id)
        expect(posts.size).to eq 9
      end
    end
    context 'キーワードで検索する' do
      before do
        FactoryBot.create(:post, text: 'テスト文字列', account_id: @current_account.id)
        FactoryBot.create(:post, text: 'テスト文字列', account_id: @other_account.id)
        FactoryBot.create(:post, text: 'ヒットしない文字列', account_id: @current_account.id)
        @post_form = PostForm.new(search_text: 'テスト')
      end
      example '該当アカウントでtextにキーワードが含まれる投稿が返ってくる' do
        posts = @post_form.search_in_accounts_show(@current_account.id)
        expect(posts.size).to eq 1
        expect(posts.first.text).to include 'テスト'
      end
    end
    context 'ハッシュタグで検索する' do
      before do
        FactoryBot.create(:hash_tag)
        FactoryBot.create(:post, account_id: @current_account.id) do |post| # 該当するハッシュタグ・該当するアカウント
          FactoryBot.create(:post_hash_tag, post_id: post.id)
        end
        FactoryBot.create(:post, account_id: @other_account.id) do |post| # アカウント違い
          FactoryBot.create(:post_hash_tag, post_id: post.id)
        end
        FactoryBot.create(:post, account_id: @current_account.id) # ハッシュタグ違い
        @post_form = PostForm.new(search_hash_tag: 'ハッシュタグ1')
      end
      example '該当アカウントでハッシュタグに紐づく投稿が返ってくる' do
        posts = @post_form.search_in_accounts_show(@current_account.id)
        expect(posts.size).to eq 1
        expect(posts.first.hash_tags.first.name).to eq 'ハッシュタグ1'
      end
    end
    context 'LPのURLで検索' do
      before do
        @post_form = PostForm.new(search_url: 'http://example.com/')
        FactoryBot.create(:landing_page) do |lp|
          FactoryBot.create(:lp_combined_url, url_hash: lp.url_hash) #ヒットするcombined_url
          FactoryBot.create(:post, url_hash: lp.url_hash, account_id: @current_account.id)
          FactoryBot.create(:post, url_hash: lp.url_hash, account_id: @other_account.id)
        end
        FactoryBot.create(:landing_page) do |lp|
          FactoryBot.create(:lp_combined_url, url_hash: lp.url_hash, combined_url: 'http://localhost:3000') #ヒットしないcombined_url
          FactoryBot.create(:post, url_hash: lp.url_hash, account_id: @current_account.id)
          FactoryBot.create(:post, url_hash: lp.url_hash, account_id: @other_account.id)
        end
      end
      example '該当アカウントで検索したURLとマッチしたLPに紐づく投稿が返ってくる' do
        posts = @post_form.search_in_accounts_show(@current_account.id)
        expect(posts.size).to eq 1
      end
    end
    context '投稿日で絞り込む' do
      before do
        # PostFormのstarted_atはデフォルトで2021/02/01
        @post_form = PostForm.new(end_date: '2021/02/28'.to_date)
        FactoryBot.create(:post, posted_at: '2021/03/01 10:00 JTC'.to_time, account_id: @current_account.id)
        FactoryBot.create(:post, posted_at: '2021/02/01 10:00 JTC'.to_time, account_id: @current_account.id)
        FactoryBot.create(:post, posted_at: '2021/02/02 10:00 JTC'.to_time, account_id: @other_account.id)
      end
      example '該当アカウントで投稿日が指定された期間内の投稿が返ってくる' do
        posts = @post_form.search_in_accounts_show(@current_account.id)
        expect(posts.size).to eq 1
        expect(I18n.l(posts.first.posted_at, format: :long)).to eq '2021/02/01 (月) 10:00'
      end
    end
    context '投稿タイプで検索' do
      before do
        FactoryBot.create(:post, account_id: @current_account.id)
        FactoryBot.create(:post, :tweet, account_id: @current_account.id)
        FactoryBot.create(:post, :feed, account_id: @other_account.id)
        @post_form = PostForm.new(post_type: 'feed')
      end
      example '該当アカウントで検索した投稿タイプと一致する投稿が返ってくる' do
        posts = @post_form.search_in_accounts_show(@current_account.id)
        expect(posts.size).to eq 1
        expect(posts.first.post_type).to eq 'feed'
      end
    end

    describe '並び替え' do
      before do
        Post.destroy_all
        FactoryBot.create(:post, like_count: 1, retweet_count: 3, posted_at: '2021/02/02 12:30 JTC'.to_time, account_id: @current_account.id)
        FactoryBot.create(:post, like_count: 2, retweet_count: 2, posted_at: '2021/02/02 12:29 JTC'.to_time, account_id: @current_account.id)
        FactoryBot.create(:post, like_count: 3, retweet_count: 1, posted_at: '2021/02/03 07:05 JTC'.to_time, account_id: @current_account.id)
        FactoryBot.create(:post, like_count: 3, retweet_count: 3, posted_at: '2021/02/03 07:05 JTC'.to_time,
                                 account_id: @other_account.id)
      end
      context 'いいね数で並び替え' do
        before { @post_form = PostForm.new(sort: 'like', end_date: '2021/02/04'.to_date) }
        example '該当アカウントでいいね数が多い順に表示される' do
          posts = @post_form.search_in_accounts_show(@current_account.id)
          expect(posts.first.like_count).to  eq 3
          expect(posts.second.like_count).to eq 2
          expect(posts.third.like_count).to  eq 1
        end
      end
      context 'リツイート数で並び替え' do
        before { @post_form = PostForm.new(sort: 'retweet', end_date: '2021/02/04'.to_date) }
        example '該当アカウントでリツイート数が多い順に表示される' do
          posts = @post_form.search_in_accounts_show(@current_account.id)
          expect(posts.first.retweet_count).to  eq 3
          expect(posts.second.retweet_count).to eq 2
          expect(posts.third.retweet_count).to  eq 1
        end
      end
      context '投稿が新しい順で並び替え' do
        before { @post_form = PostForm.new(sort: 'posted_at', end_date: '2021/02/04'.to_date) }
        example '該当アカウントで投稿日時が新しい順に表示される' do
          posts = @post_form.search_in_accounts_show(@current_account.id)
          expect(I18n.l(posts.first.posted_at, format: :long)).to eq '2021/02/03 (水) 07:05'
          expect(I18n.l(posts.second.posted_at, format: :long)).to eq '2021/02/02 (火) 12:30'
          expect(I18n.l(posts.third.posted_at, format: :long)).to eq '2021/02/02 (火) 12:29'
        end
      end
      context '何も指定しない' do
        before { @post_form = PostForm.new(end_date: '2021/02/04'.to_date) }
        example '該当アカウントで投稿日時が新しい順に表示される' do
          posts = @post_form.search_in_accounts_show(@current_account.id)
          expect(I18n.l(posts.first.posted_at, format: :long)).to eq '2021/02/03 (水) 07:05'
          expect(I18n.l(posts.second.posted_at, format: :long)).to eq '2021/02/02 (火) 12:30'
          expect(I18n.l(posts.third.posted_at, format: :long)).to eq '2021/02/02 (火) 12:29'
        end
      end
      context '存在しない並び替え方法を指定する' do
        before { @post_form = PostForm.new(sort: 'hoge_sort', end_date: '2021/02/04'.to_date) }
        example '一つもレコードが返ってこない' do
          pending '1つもレコードが返らないのが正しいのかすべて返すのが正しいのかわからないので'
          posts = @post_form.search_in_accounts_show(@current_account.id)
          expect(posts.size).to eq 0
        end
      end
    end
  end
end
