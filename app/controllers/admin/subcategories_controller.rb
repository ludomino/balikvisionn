module Admin
  class SubcategoriesController < Admin::BaseController
    def destroy
      @category = Category.find(params[:category_id])
      @subcategory = @category.subcategories.find(params[:id])
      @subcategory.destroy
      redirect_to admin_category_path(@category), notice: 'Subcategory was successfully destroyed.'
    end

    def edit
      @category = Category.find(params[:category_id])
      @subcategory = @category.subcategories.find(params[:id])
    end

    def update
      @category = Category.find(params[:category_id])
      @subcategory = @category.subcategories.find(params[:id])

      if @subcategory.update(subcategory_params)
        redirect_to admin_category_path(@category), notice: 'Subcategory was successfully updated.'
      else
        render :edit
      end
    end

    def new
      @category = Category.find(params[:category_id])
      @subcategory = Subcategory.new
    end

    def create
      @category = Category.find(params[:category_id])
      @subcategory = Subcategory.new(subcategory_params)
      @subcategory.category = @category

      if @subcategory.save
        redirect_to admin_category_path(@category), notice: 'Subcategory was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def subcategory_params
      params.require(:subcategory).permit(:name, :description, photos: [])
    end
  end
end
