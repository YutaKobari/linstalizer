module Pankuzu
  def set_pankuzu
    @pankuzu = pankuzu_element
  end

  def pankuzu_element
    case self.class.name
    when "AccountsController"
      case self.action_name
      when "index"
        media = params[:media] || '全メディア'
        [
          {
            text: "アカウント検索",
            href: accounts_path
          },
          {
            text: media,
            href: "",
            class: "disable_a"
          }
        ]
      when "show"
        account = Account.find(params[:id])
        [
          {
            text: "アカウント検索",
            href: accounts_path
          },
          {
            text: account.media,
            href: accounts_path(media: account.media)
          },
          {
            text: account.name,
            href: "",
            class: "disable_a"
          }
        ]
      end
    when "BrandsController"
      case self.action_name
      when "show"
        brand = Brand.find(params[:id])
        [
          {
            text: "アカウント検索",
            href: accounts_path
          },
          {
            text: "全メディア",
            href: accounts_path
          },
          {
            text: brand.name,
            href: "",
            class: "disable_a"
          }
        ]
      end
    when "PostsController"
      case self.action_name
      when "index"
        media = params[:media] || '全メディア'
        [
          {
            text: "投稿検索",
            href: posts_path
          },
          {
            text: media,
            href: "",
            class: "disable_a"
          }
        ]
      when "show"
        post = Post.find(params[:id])
        [
          {
            text: "アカウント検索",
            href: accounts_path
          },
          {
            text: post.media,
            href: accounts_path(media: post.media)
          },
          {
            text: post.account.name,
            href: account_path(id: post.account.id)
          },
          {
            text: "投稿詳細",
            href: "",
            class: "disable_a"
          }
        ]
      end
    when "TalkPostsController"
      case self.action_name
      when "index"
        [
          {
            text: "トーク投稿検索",
            href: "",
            class: "disable_a"
          },
        ]
      when "show"
      talk_post = TalkPost.find(params[:id])
        [
          {
            text: 'トーク投稿検索',
            href: talk_posts_path
          },
          {
            text: 'LINE',
            href: accounts_path(media: 'LINE')
          },
          {
            text: talk_post.account.name,
            href: account_path(id: talk_post.account.id)
          },
          {
            text: 'トーク投稿詳細',
            href: "",
            class: "disable_a"
          }
        ]
      end
    when "LandingPagesController"
      case self.action_name
      when "index"
        [
          {
            text: "LP検索",
            href: "",
            class: "disable_a"
          },
        ]
      when "show"
        [
          {
            text: "LP検索",
            href: landing_pages_path
          },
          {
            text: "LP詳細",
            href: "",
            class: "disable_a"
          }
        ]
      end
    when "HashTagsController"
      case self.action_name
      when "index"
        [
          {
            text: "ハッシュタグ一覧",
            href: "",
            class: "disable_a"
          },
        ]
      end
    end
  end
end
