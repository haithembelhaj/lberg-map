module PlacesHelper
  def generate_categories_filter_links(place)
    raw place.categories.map { |c| link_to c.name, category_path(c.id) }.join(', ')
  end

  # Versioning stuff
  def get_version_index(obj, version_id)
    obj.versions.map(&:id).find_index(version_id)
  end

  def adjecent_version_id(obj, current_version_id, direction)
    current_version_id ||= obj.versions.last.id
    current_version_index = get_version_index(obj, current_version_id.to_i)
    version_id = obj.versions.map(&:id)[current_version_index + direction]
    current_version_index + direction < 0 ? nil : version_id
  end

  def get_version_date(current_version_id)
    PaperTrail::Version.find(current_version_id).created_at.strftime('%d.%m.%y %T')
  end

  def provide_place_version_browsing
    links = []
    if previous_version_id = adjecent_version_id(@place, @current_version_ids[:place], -1)
      links << link_to('< Previous change ',
                       place_version: previous_version_id,
                       translations_versions: @current_version_ids[:translations])
    end
    links << "(#{get_version_date(@current_version_ids[:place])})"
    if next_version_id = adjecent_version_id(@place, @current_version_ids[:place], +1)
      links << link_to('Next change >',
                       place_version: next_version_id,
                       translations_versions: @current_version_ids[:translations])
    end
    raw links.join(' ')
  end

  def provide_translation_version_browsing(translation)
    language = translation.locale.to_s
    links = []
    prev_translation_version = @current_version_ids[:translations].dup
    if previous_version_id = adjecent_version_id(translation, prev_translation_version[language], -1)
      prev_translation_version[language] = previous_version_id
      links << link_to('< Previous change ',
                       translations_versions: prev_translation_version,
                       place_version: adjecent_version_id(@place, @current_version_ids[:place], 0))
    end
    links << "(#{get_version_date(@current_version_ids[:translations][language])})"
    next_translation_version = @current_version_ids[:translations].dup
    if next_version_id = adjecent_version_id(translation, next_translation_version[language], +1)
      next_translation_version[language] = next_version_id
      links << link_to('Next change >',
                       translations_versions: next_translation_version,
                       place_version: adjecent_version_id(@place, @current_version_ids[:place], 0))
    end
    raw links.join(' ')
  end
end
