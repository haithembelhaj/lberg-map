class StaticPagesController < ApplicationController
  def map
    @places = Place.all
    @categories = Category.all
    @places_json = Place.all.map(&:geojson)
  end

  def about
  end
end
