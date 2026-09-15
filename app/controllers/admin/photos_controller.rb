module Admin
  class PhotosController < Admin::BaseController
    before_action :set_photo

    def move_higher
      @photo.move_higher
      redirect_to edit_admin_category_subcategory_path(@subcategory.category, @subcategory)
    end

    def move_lower
      @photo.move_lower
      redirect_to edit_admin_category_subcategory_path(@subcategory.category, @subcategory)
    end

    private

    # Scope par sous-catégorie : cohérent avec le pattern des autres contrôleurs admin
    def set_photo
      @subcategory = Subcategory.find(params[:subcategory_id])
      @photo = @subcategory.photos.find(params[:id])
    end
  end
end
