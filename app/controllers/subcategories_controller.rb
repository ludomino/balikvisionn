class SubcategoriesController < ApplicationController
  def show
    @category = Category.find(params[:category_id])
    @subcategory = @category.subcategories.published.find(params[:id])
  end
end
