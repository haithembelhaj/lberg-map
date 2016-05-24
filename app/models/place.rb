class Place < ActiveRecord::Base
  ## RELATIONS
  has_many :categorizings
  has_many :categories, through: :categorizings

  ## VALIDATIONS
  validates_presence_of :name, :street, :city, :postal_code
  validates :postal_code, format: { with: /\d{5}/, message: 'upply valid postal code (5 digits)' }
  validate :valid_geocode?

  ## TRANSLATION
  translates :description
  globalize_accessors

  ## CALLBACKS
  geocoded_by :address
  before_validation :geocode, if: :address_changed?, on: [:create, :update]
  before_validation :sanitize_descriptions, on: [:create, :update]

  ## CATEGORY TAGGING
  def category_ids=(ids)
    clean_ids = ids.reject(&:empty?)
    if clean_ids == []
      self.categories.destroy_all
    else
      self.categories = clean_ids.map do |id|
        Category.where(id: id.to_i).first
      end
    end
  end

  def self.tagged_with(id)
    category = Category.find(id)
    category && category.places
  end

  ## GEOCODING
  def valid_geocode?
    address_string = "#{street} #{house_number}, #{postal_code}, #{city}"
    address = Geocoder.search(address_string).first
    errors.add(:address, :address_not_found) unless address && address.type == 'house'
  end

  def address
    "#{street} #{house_number}, #{postal_code} #{city}"
  end

  def address_changed?
    street_changed? || city_changed? || house_number_changed? || postal_code_changed?
  end

  ## SANITIZE
  def sanitize_descriptions
    I18n.available_locales.each do |locale|
      column = "description_#{locale}"
      self.send(column + '=', sanitize(self.send(column)))
    end
  end

  def sanitize(html)
    Rails::Html::WhiteListSanitizer.new.sanitize(
      html,
      tags: %w[u i b li ol hr font],
      attributes: %w[align color size]
    )
  end

  ## PROPERTIES
  def geojson
    {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [self.latitude, self.longitude],
      },
      properties: properties,
    }
  end

  def properties
    self.attributes.each do |_key, value|
      { key: value }
    end.merge!(address: address, description: description_texts)
  end

  def description_texts
    self.description
  end
end
