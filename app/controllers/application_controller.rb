class ApplicationController < ActionController::Base
  include SessionsHelper
  around_action :switch_locale

  private
  def switch_locale &action
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def extract_locale_from_tld
    parsed_locale = request.host.split(".").last
    locales = I18n.available_locales.map(&:to_s)
    locales.include?(parsed_locale) ? parsed_locale : nil
  end
end
