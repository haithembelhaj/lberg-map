class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale
  helper_method :current_user, :signed_in?, :is_admin?
  before_filter :set_paper_trail_whodunnit

  def set_locale
    if params[:locale]
      I18n.locale = params[:locale]
    else
      @local_not_selected = true
    end
  end

  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def signed_in?
    !current_user.nil?
  end

  def is_admin?
    signed_in? && @current_user.is_admin
  end

  def latest_translation_versions(obj)
    obj.translations.map { |t| [t.locale, t.versions.last.id] }.to_h
  end
end
