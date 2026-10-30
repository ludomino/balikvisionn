class SitemapController < ApplicationController
  def index
    @categories = Category.published
    @subcategories = Subcategory.published.includes(:category)

    respond_to do |format|
      format.xml
    end
  end
end
