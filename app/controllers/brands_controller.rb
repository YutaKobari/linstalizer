class BrandsController < ApplicationController
  def show
    @brand = Brand.find(params[:id])
    @heatmap = Heatmap.new(@brand, heatmap_params)
    post_form = PostForm.new(post_params)
    @posts = post_form.search_in_brands_show(@brand.id).page(params[:page]).without_count.per(30)
  end

  def append_modal
    @posts = if params[:post_type] == "talk_post"
      TalkPost.where(day: params[:day], hour: params[:hour], brand_id: params[:brand_id])
    else
      Post.where(day: params[:day], hour: params[:hour], media: params[:media], post_type: params[:post_type], brand_id: params[:brand_id])
    end
    respond_to do |format|
      format.js
    end
  end

  private

  def heatmap_params
    params.permit(
      :aggregated_from,
      :aggregated_to,
      :current_tab,
      media_post_types: [],
    )
  end

  def post_params
    params.permit(
      :search_text,
      #:search_account,
      :search_hash_tag,
      :search_url,
      :media,
      :post_type,
      :start_date,
      :end_date,
      :sort
    )
  end
end
