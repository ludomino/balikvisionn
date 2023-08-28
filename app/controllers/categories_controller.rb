class CategoriesController < ApplicationController
  # before_action :set_kart, only: [:show, :destroy]
  # skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @categories = Category.all
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to root_path(@category), notice: 'Category was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @category = Category.find(params[:id])
    @category.destroy
    redirect_to root_path(@category), status: :see_other, notice: 'Category was successfully destroyed.'
  end

  def edit
    @category = Category.find(params[:id])
  end

  def new
    @category = Category.new
  end

  def show
    @category = Category.find(params[:id])
    @subcategories = @category.subcategories
  end

  def update
    @category = Category.find(params[:id])
    if @category.update(category_params)
      redirect_to root_path(@category), notice: 'Category was successfully updated.'
    else
      render :edit
    end
  end

  private

  def category_params
    params.require(:category).permit(:name, :cover)
  end
end
