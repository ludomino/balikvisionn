class AboutController < ApplicationController
  def show
    @about_page = AboutPage.instance
  end
end
