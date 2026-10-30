class SubcategoriesController < ApplicationController
  def show
    @category = Category.published.find(params[:category_id])
    @subcategory = @category.subcategories.published.find(params[:id])
  end
end
