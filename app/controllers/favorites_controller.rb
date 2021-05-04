class FavoritesController < ApplicationController
  before_action :set_account_and_is_account_show

  def create
    @favorite = Favorite.create(user_id: current_user.id, account_id: @account.id)
    render 'favorite'
  end

  def destroy
    @favorite = Favorite.find_by(user_id: current_user.id, account_id: @account.id)
    @favorite.destroy
    render 'favorite'
  end

  private

  def set_account_and_is_account_show
    @account = Account.find(params[:account_id])
    @is_account_show = params[:is_account_show]
  end
end
