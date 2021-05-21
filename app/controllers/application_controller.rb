require 'csv'

class ApplicationController < ActionController::Base
  include Pankuzu
  add_flash_types :success, :info, :warning, :danger
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!, except: [:new, :create]
  before_action :log_access
  before_action :set_pankuzu
  before_action :set_title
  before_action :set_filter_form_open
  before_action :set_current_user
  before_action :set_favorite_account_ids

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  # 利用先のユーザーをGoogle Analyticsで分類するためのパラメータを付与
  def default_url_options(options = {})
    default_options = {
      utm_source: params[:utm_source],
      utm_medium: params[:utm_medium]
    }
    options.merge default_options
  end

  def log_access
    header_str = request.headers.sort.map {|k, v| "#{k}:#{v}"}.join("\n")
    AccessLog.create(
      user_id: current_user&.id,
      url: request&.fullpath,
      headers: header_str,
      env: Rails.env,
      controller: self.controller_name,
      action: self.action_name
    )
  end

  def set_current_user
    User.current = current_user
  end

  def set_favorite_account_ids
    @favorite_account_ids = current_user.accounts.pluck(:id) if current_user
  end

  def set_title
    @title = @pankuzu&.map{|p| p[:text]}&.join(' | ')
    if @title.present?
      @title += " | SNSクロール"
    else
      @title = nil
    end
  end

  def set_filter_form_open
    @filter_form_open = params[:filter_form_open] || false
  end
end
