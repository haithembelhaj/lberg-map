class Category < ActiveRecord::Base
  has_many :categorizings
  has_many :places, through: :categorizings

  translates :name
  globalize_accessors
end
