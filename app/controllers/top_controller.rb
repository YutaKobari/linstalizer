class TopController < ApplicationController
  def index
    @notifications = Notification.active_notifications
    @fav_accounts = AccountForm.new(is_favorite: 1, sort: 'max_posted_at').search
    @fav_posts = PostForm.new(is_favorite: 1).search.page(params[:posts_page]).without_count.per(15)
    @fav_talks = TalkPostForm.new(is_favorite: 1).search.page(params[:talks_page]).without_count.per(15)
  end
end
