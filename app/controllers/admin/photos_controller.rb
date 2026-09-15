module Admin
  class PhotosController < Admin::BaseController
    before_action :set_subcategory
    before_action :set_photo, only: [:move_higher, :move_lower, :destroy]

    def move_higher
      @photo.move_higher
      redirect_to edit_admin_category_subcategory_path(@subcategory.category, @subcategory)
    end

    def move_lower
      @photo.move_lower
      redirect_to edit_admin_category_subcategory_path(@subcategory.category, @subcategory)
    end

    def destroy
      @photo.destroy
      redirect_to edit_admin_category_subcategory_path(@subcategory.category, @subcategory), notice: "Photo supprimée."
    end

    # Persiste le nouvel ordre après un glisser-déposer (liste complète d'ids, pas un swap)
    def reorder
      params[:photo_ids].each_with_index do |photo_id, index|
        @subcategory.photos.where(id: photo_id).update_all(position: index)
      end
      head :ok
    end

    private

    def set_subcategory
      @subcategory = Subcategory.find(params[:subcategory_id])
    end

    def set_photo
      @photo = @subcategory.photos.find(params[:id])
    end
  end
end
