require 'test_helper'

class PlacesControllerTest < ActionController::TestCase
  def post_some_place
    post :create, place: { name: 'SomePlace',
                           street: 'Schulze-Boysen-Straße',
                           house_number: '15',
                           postal_code: '10365',
                           city: 'Berlin',
                           description_en: 'This is some place'
                          }
  end

  # Places
  test 'Updating a point increases number of versions' do
    post_some_place
    p = Place.find_by_name('SomePlace')
    assert_difference 'p.versions.length' do
      p.update_attributes(name: 'SomeOtherPlace')
    end
  end

  test 'Version is 1 for new points' do
    post_some_place
    p = Place.find_by_name('SomePlace')
    assert_equal 1, p.versions.length
  end

  test 'Updating translation record does not increase associated place versions' do
    post_some_place
    p = Place.find_by_name('SomePlace')
    assert_difference 'p.versions.length', 0 do
      p.translation.update_attributes(description: 'This is some edit')
    end
  end

  # Translations
  test 'Version is 1 for new translations' do
    post_some_place
    p = Place.find_by_name('SomePlace')
    p.translations.each do |t|
      assert_equal 1, t.versions.length
    end
  end

  test 'Updating place record does not increase any translation version' do
    post_some_place
    p = Place.find_by_name('SomePlace')
    p.translations.each do |t|
      assert_difference 't.versions.length', 0 do
        p.update_attributes(name: ('a'..'z').to_a.sample)
      end
    end
  end

  test 'Translation version numbers is increased by 1 on update' do
    post_some_place
    p = Place.find_by_name('SomePlace')
    p.translations.each do |t|
      assert_difference 't.versions.length', 1 do
        t.update_attributes(description: ('a'..'z').to_a.sample)
      end
    end
  end
end
