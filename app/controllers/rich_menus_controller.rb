class RichMenusController < ApplicationController
  before_action :find_rich_menu, only: [:show]
  def index
    rich_menu_form = RichMenuForm.new(rich_menu_params)
    @rich_menus = rich_menu_form.search.page(params[:page]).without_count.per(50)
  end

  def show
    @rich_menu_contents = RichMenuContent.where(group_hash: @rich_menu.group_hash)
  end

  private

  def rich_menu_params
    params.permit(
      :search_text,
      :search_account,
      :market_id,
      :search_url,
      :start_date,
      :end_date,
      :sort,
      :is_favorite,
    )
  end

  def find_rich_menu
    @rich_menu = RichMenu.find(params[:id])
  end
end
