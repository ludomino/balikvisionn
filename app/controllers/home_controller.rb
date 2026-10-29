class HomeController < ApplicationController
  def index
    @home_features = HomeFeature.includes(:featurable).order(:position)
  end
end
