class HomeController < ApplicationController
  def index
    @home_features = HomeFeature.includes(:featurable).order(:position).select(&:publicly_visible?)
  end
end
