class CategoriesController < ApplicationController
  def index
    @categories = Category.published.order(:position)
  end

  def show
    @category = Category.published.find(params[:id])
    @subcategories = @category.subcategories.published
  end
end
