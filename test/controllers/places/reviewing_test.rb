require 'test_helper'

class PlacesControllerTest < ActionController::TestCase
  def setup
    @place = places :Magda19
    @user = users :Norbert
  end

  def post_some_place
    post :create, place: { name: 'SomePlace',
                           street: 'Schulze-Boysen-Straße',
                           house_number: '15',
                           postal_code: '10365',
                           city: 'Berlin',
                           description_en: 'This is some place'
                          }
  end

  # Place
  test 'can access review if logged in' do
    @place.save
    @place.reload
    session['user_id'] = @user.id
    get :index_unreviewed, id: @place.id
    assert_response :success
  end

  test 'cannot review if not logged in' do
    session[:user_id] = nil
    @place.save
    @place.reload
    get :index_unreviewed, id: @place.id
    assert_response :redirect
  end

  test 'review flag true if signed in on create' do
    session[:user_id] = @user.id
    post_some_place
    assert Place.find_by(name: 'SomePlace').reviewed
  end

  test 'review flag false if not logged in on create' do
    session[:user_id] = nil
    post_some_place
    assert_not Place.find_by(name: 'SomePlace').reviewed
  end

  # Translations
  test "review flag true on translation if signed in on update" do
    session[:user_id] = @user.id
    post_some_place
    t = Place.find_by(name: 'SomePlace').translations.find_by(locale: 'en')
    assert t.reviewed
  end
end
