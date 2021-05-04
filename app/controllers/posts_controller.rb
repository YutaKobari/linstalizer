class PostsController < ApplicationController
  before_action :find_post, only: [:show]
  def index
    post_form = PostForm.new(post_params)
    @posts = post_form.search.page(params[:page]).without_count.per(50)
  end

  def show
  end

  private

  def post_params
    params.permit(
      :search_text,
      :search_account,
      :market_id,
      :search_hash_tag,
      :search_url,
      :media,
      :post_type,
      :start_date,
      :end_date,
      :sort,
      :is_favorite,
    )
  end

  def find_post
    @post = Post.find params[:id]
  end
end
