class HashTagsController < ApplicationController

  def index
    hash_tag_form = HashTagForm.new(hash_tag_params)
    @hash_tags = hash_tag_form.search.page(params[:page]).without_count.per(50)
    @aggregated_from = params[:aggregated_from]&.to_date || Date.today - 6.days
    @aggregated_to = params[:aggregated_to]&.to_date || Date.today
  end

  private

  def hash_tag_params
    params.permit(
      :search_hash_tag,
      :aggregated_from,
      :aggregated_to,
      :sort,
      :media
    )
  end
end
