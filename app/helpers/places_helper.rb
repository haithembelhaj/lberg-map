module PlacesHelper
  def generate_categories_filter_links(place)
    raw place.categories.map { |c| link_to c.name, category_path(c.id) }.join(', ')
  end

  # Versioning stuff
  def get_version_index(obj, version_id)
    obj.versions.map(&:id).find_index(version_id)
  end

  def get_adjecent_version_id(obj, current_version_id, direction)
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
    links << "#{get_version_date(@current_version_ids[:place.to_sym])}: "
    previous_version_id = get_adjecent_version_id(@place, @current_version_ids[:place], -1)
    debugger
    if previous_version = @place.previous_version
      links << link_to('< Previous change ',
                       place_version: previous_version_id,
                       translations_versions: @current_version_ids[:translations])
    end
    if next_version_id = get_adjecent_version_id(@place, @current_version_ids[:place], +1)
      links << link_to('Next change >',
                       place_version: next_version_id,
                       translations_versions: @current_version_ids[:translations])
    end
    raw links.join(' ')
  end

  def provide_translation_version_browsing(translation)
    language = translation.locale.to_s
    links = ["(#{get_version_date(@current_version_ids[:translations][language.to_sym])})"]
    # Strange variable init
    previous_translations_versions_ids = @current_version_ids[:translations].dup
    previous_translation_version_id = get_adjecent_version_id(translation, previous_translations_versions_ids[language], -1)
    previous_version = translation.previous_version if previous_translation_version_id
    if previous_version && !previous_version.reviewed
      previous_translations_versions_ids[language] = previous_version_id
      links << link_to('< Previous change ',
                       translations_versions: previous_translations_versions_ids,
                       place_version: get_adjecent_version_id(@place, @current_version_ids[:place], 0))
    end
    # ...same
    next_translations_versions_ids = @current_version_ids[:translations].dup
    previous_translations_versions_ids = @current_version_ids[:translations].dup
    next_translation_version_id = get_adjecent_version_id(translation, next_translations_versions_ids[language], +1)
    next_version = translation.next_version if next_translation_version_id
    if next_version && !next_version.reviewed
      next_translations_versions_ids[language] = next_translation_version_id
      links << link_to('Next change >',
                       translations_versions: next_translations_versions_ids,
                       place_version: get_adjecent_version_id(@place, @current_version_ids[:place], 0))
    end
    raw links.join(' ')
  end
end
