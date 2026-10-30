class SitemapController < ApplicationController
  def index
    @categories = Category.all
    @subcategories = Subcategory.published.includes(:category)

    respond_to do |format|
      format.xml
    end
  end
end
