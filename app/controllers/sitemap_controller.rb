class SitemapController < ApplicationController
  def index
    @categories = Category.all

    respond_to do |format|
      format.xml
    end
  end
end
