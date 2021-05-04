class LandingPagesController < ApplicationController
  def index
    lp_form = LpForm.new(lp_params)
    @landing_pages = lp_form.search.page(params[:page]).without_count.per(50)
  end

  def show
    @lp = LandingPage.find_by(id: params[:id])
    post_form = PostForm.new(post_params)
    @posts = post_form.search_in_lp_show(@lp.id).page(params[:page]).without_count.per(30)
  end

  private

  def lp_params
    params.permit(
      :search_text    ,
      :market_id      ,
      :search_url     ,
      :media          ,
      :start_date     ,
      :end_date       ,
      :sort           ,
      :is_favorite    ,
    )
  end

  def post_params
    params.permit(
      :search_text,
      :search_hash_tag,
      :media,
      :post_type,
      :start_date,
      :end_date,
      :sort
    )
  end
end
