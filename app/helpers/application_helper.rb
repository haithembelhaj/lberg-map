module ApplicationHelper
  def text_direction
    'rtl' if locale.to_s == 'ar'
  end

  def locale_to_name(locale)
    t('language', locale: locale)
  end
end
