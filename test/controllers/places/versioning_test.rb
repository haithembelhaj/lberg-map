require 'test_helper'

class PlacesControllerTest < ActionController::TestCase
  # Places
  test 'Updating a point increases number of versions' do
    post :create, place: { name: 'SomePlace',
                           street: 'Schulze-Boysen-Straße',
                           house_number: '15',
                           postal_code: '10365',
                           city: 'Berlin' }
    p = Place.find_by_name('SomePlace')
    assert_difference 'p.versions.length' do
      p.update_attributes(name: 'SomeOtherPlace')
    end
  end

  test 'Version is 1 for new points' do
    post :create, place: { name: 'SomePlace',
                           street: 'Schulze-Boysen-Straße',
                           house_number: '15',
                           postal_code: '10365',
                           city: 'Berlin',
                          }
    p = Place.find_by_name('SomePlace')
    assert_equal 1, p.versions.length
  end

  test 'Updating translation record does not increase associated place versions' do
    post :create, place: { name: 'SomePlace',
                           street: 'Schulze-Boysen-Straße',
                           house_number: '15',
                           postal_code: '10365',
                           city: 'Berlin',
                           description_en: 'This is some place'
                          }
    p = Place.find_by_name('SomePlace')
    assert_difference 'p.versions.length', 0 do
      p.update_attributes(description_en: 'This is some edit')
    end
  end

  # Translations
  test "Updating place record does not increase any translation version" do
    skip
  end

  test "Version is 1 for new translations" do
    skip
  end

  test "Translation version numbers is increased by 1 on update" do
    skip
  end

  test "Translation version numbers is increased by 1 on update" do
    skip
  end

  # Associations

end
