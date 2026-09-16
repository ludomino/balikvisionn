module Admin
  class CategoriesController < Admin::BaseController
    def index
      @categories = Category.all
    end

    def show
      @category = Category.find(params[:id])
      @subcategories = @category.subcategories
    end

    def new
      @category = Category.new
    end

    def create
      @category = Category.new(category_params)
      if @category.save
        redirect_to admin_category_path(@category), notice: 'Catégorie créée avec succès.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @category = Category.find(params[:id])
    end

    def update
      @category = Category.find(params[:id])
      if @category.update(category_params)
        redirect_to admin_category_path(@category), notice: 'Catégorie mise à jour avec succès.'
      else
        render :edit
      end
    end

    def destroy
      @category = Category.find(params[:id])
      @category.destroy
      redirect_to admin_categories_path, status: :see_other, notice: 'Catégorie supprimée avec succès.'
    end

    private

    def category_params
      params.require(:category).permit(:name, :cover)
    end
  end
end
