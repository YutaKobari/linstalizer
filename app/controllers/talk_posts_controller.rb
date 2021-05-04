class TalkPostsController < ApplicationController
  before_action :find_talk_post, only: [:show]
  def index
    post_form = TalkPostForm.new(post_params)
    @talk_post_contents = post_form.search.page(params[:page]).without_count.per(50)
  end

  def show
  end

  def post_params
    params.permit(
      :search_text,
      :search_account,
      :search_url,
      :market_id,
      :post_type,
      :start_date,
      :end_date,
      :is_favorite,
    )
  end

  private

  def find_talk_post
    @talk_post = TalkPost.find(params[:id])
  end
end
