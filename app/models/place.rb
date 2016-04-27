class Place < ActiveRecord::Base
  has_many :descriptions, :dependent => :delete_all
  accepts_nested_attributes_for :descriptions

  geocoded_by :address
  before_validation :geocode, :if => :address_changed?

  validates :address, :street, :city, :postal_code, presence: true
  validates :postal_code, format: { with: /\d{5}/, message: "Supply valid postal code (5 digits)" }

  validates :name, presence: true
  validates :longitude, presence: true,
                        numericality: { less_than_or_equal_to: 90, greater_than_or_equal_to: -90 }
  validates :latitude, presence: true,
                       numericality: { less_than_or_equal_to: 180, greater_than_or_equal_to: -180 }
  validates :categories, presence: true

  def address
    "#{street} #{house_number}, #{postal_code}, #{city}"
  end

  def address_changed?
    street_changed? || city_changed? || house_number_changed? || postal_code_changed?
  end

  # def address_changed?
  #   attrs = %w(street house_number postal_code city)
  #   attrs.any?{|a| send "#{a}_changed?"}
  # end

  def geojson
    {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [self.latitude, self.longitude],
      },
      properties: {
        name: self.name,
        categories: self.categories,
      },
    }
  end
end
