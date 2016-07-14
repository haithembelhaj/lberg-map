class PlacesController < ApplicationController
  # http_basic_authenticate_with name: 'admin', password: 'secret'
  include SimpleCaptcha::ControllerHelpers
  before_action :require_login, only: [:index_unreviewed, :review, :update_reviewed]

  def index
    if params[:category]
      @places = Place.tagged_with(params[:category])
    else
      @places = Place.all
    end
  end

  def edit
    @place = Place.find(params[:id])
    flash.now[:warning] = 'You are currently in preview mode, changes you make have to be reviewed before they
    become published!' unless signed_in?
  end

  # Reviewing
  def index_unreviewed
    @places = Place.where(reviewed: false).order('updated_at DESC').paginate(page: params[:page], per_page: 15)
  end

  def review
    @place = Place.find(params[:id])
    @current_version_ids = {
      place: params[:place_version] || @place.versions.last.id,
      translations: params[:translations_versions] || latest_translation_versions(@place)
    }
    @place = @place.versions.find(@current_version_ids[:place].to_i).reify || @place
    @translations = @place.translations.map do |t|
      t.versions.find(@current_version_ids[:translations][t.locale].to_i).reify || t
    end
    @last_reviewed_place = @place.last_reviewed_version_of(@place)
  end

  def update
    @place = Place.find(params[:id])
    @place.reviewed = (signed_in? ? true : false)
    if simple_captcha_valid? || signed_in?
      save_translations_updates
      save_place_update
    else
      flash.now[:danger] = 'Captcha not valid!'
      render :edit
    end
  end

  def new
    if params[:longitude] && params[:latitude]
      query = params[:latitude].to_s + ',' + params[:longitude].to_s
      @geocoded = Geocoder.search(query).first.data['address']
    end
    @place = Place.new
    flash.now[:warning] = 'You are currently in preview mode, changes you make have to be reviewed before they
    become published!' unless signed_in?
  end

  def create
    @place = Place.new(place_params)
    @place.reviewed = true if signed_in?
    if simple_captcha_valid? || signed_in?
      save_new
    else
      flash.now[:danger] = 'Captcha not valid!'
      render :new
    end
  end

  def destroy
    @place = Place.find(params[:id])
    @place.categorizings.destroy_all
    @place.destroy
    redirect_to action: 'index'
  end

  private

  def save_new
    if @place.save
      flash[:success] = 'Point successfully created!'
      redirect_to action: 'index'
    else
      flash.now[:danger] = @place.errors.full_messages.to_sentence
      render :new
    end
  end

  # Save Updates on places and translations seperately in order to not accidentally create duplicate versions
  def extract_place_attr_from(place_params)
    place_params.keys.grep(/^(description_)/).map do |k|
      [k, place_params[k]]
    end.to_h
  end

  def extract_translation_attr_from(place_params)
    place_params.keys.grep(/description_/).map do |k|
      [k, place_params[k]]
    end.to_h
  end

  def changed_descriptions
    changes = extract_translation_attr_from(place_params).keys.map do |descr_in_lang|
      locale = descr_in_lang.split('_').last
      translation = @place.translations.find_by(locale: locale)
      translation.description = params['place'][descr_in_lang]
      [locale, translation.changes]
    end
    changes.select { |_k, v| !v.empty? }.to_h
  end

  def save_translations_updates
    changed_descriptions.each do |locale, description_changes|
      translation = @place.translations.find_by(locale: locale)
      translation.update_attributes(reviewed: (signed_in? ? true : false),
                                    description: description_changes['description'].last)
    end
  end

  def save_place_update
    if @place.update_attributes(extract_place_attr_from(place_params))
      flash.now[:success] = 'Point successfully changed!'
      redirect_to places_path
    else
      flash.now[:danger] = @place.errors.full_messages.to_sentence
      render :edit
    end
  end

  def place_params
    params.require(:place).permit(
    :name, :street, :house_number, :postal_code, :city,
    :description_en, :description_de, :description_fr, :description_ar, :version,
    category_ids: []
    )
  end

  def require_login
    unless signed_in?
      flash.now[:danger] = 'Access to this page has been restricted. Please login first!'
      redirect_to login_path
    end
  end

  def make_revert_link
    view_context.link_to 'Revert changes!', revert_path(@place.versions.last), method: :post
  end
end
