class AccountsController < ApplicationController

  def index
    account_form = AccountForm.new(account_params)
    @accounts = account_form.search.page(params[:page]).without_count.per(50)
  end

  def show
    @account = Account.find(params[:id])
    @talk_post_contents = @account.fetch_talk_posts(talk_post_params).page(params[:talk_post_page]).without_count.per(30) if @account.media == 'LINE'
    @posts = @account.fetch_posts(post_params)                       .page(params[:page]).without_count.per(30)
    @rich_menus = @account.fetch_rich_menus(rich_menu_params)        .page(params[:rich_menu_page]).without_count.per(30) if @account.media == 'LINE'
    @follower_per_date = @account.fetch_follower_per_date(params[:follower_transition_month])
  end

  private

  def account_params
    params.permit(
      :search_account,
      :market_id,
      :media,
      :aggregated_from,
      :aggregated_to,
      :sort,
      :is_favorite,
      :follower_transition_month,
    )
  end

  def post_params
    params.permit(
      :current_tab,
      :search_text,
      #:search_account,
      :search_hash_tag,
      :search_url,
      #:media,
      :post_type,
      :start_date,
      :end_date,
      :sort
    )
  end

  def talk_post_params
    params.permit(
      :current_tab,
      :search_text,
      #:search_account,
      :search_url,
      :post_type,
      :start_date,
      :end_date
    )
  end

  def rich_menu_params
    params.permit(
      :current_tab,
      :search_text,
      #:search_account,
      :search_url,
      :start_date,
      :end_date,
      :sort
    )
  end
end
