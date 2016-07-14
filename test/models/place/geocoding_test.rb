require 'test_helper'

class PlaceTest < ActiveSupport::TestCase
  def setup
    @place = Place.new(name: 'Kiezspinne',
                       street: 'Schulze-Boysen-Straße',
                       house_number: '13',
                       postal_code: '10365',
                       city: 'Berlin',
                       description_en: '<center><b>This is the description.</b></center>')
  end

  test 'geocoding_with_nodes returns false if address not found' do
    @place.save
    @place.reload
    debugger
    assert @place.latitude
    assert @place.longitude
  end
end
