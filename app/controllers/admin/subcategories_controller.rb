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
        attach_photos(@subcategory)
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
        attach_photos(@subcategory)
        redirect_to admin_category_path(@category), notice: 'Subcategory was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

          private

      def subcategory_params
        # photos: [] retiré (géré par attach_photos) ; photos_attributes : édition d'alt_text uniquement
        params.require(:subcategory).permit(:name, :description, photos_attributes: [:id, :alt_text])
      end

      def uploaded_photo_files
        # .reject(&:blank?) : filtre l'entrée "" observée dans photos[] en prod
        (params.dig(:subcategory, :photos) || []).reject(&:blank?)
      end

      # Un Photo par fichier valide, position croissante, colspan 1 par défaut
      def attach_photos(subcategory)
        next_position = subcategory.photos.maximum(:position).to_i + 1
        rejected = []

        uploaded_photo_files.each_with_index do |file, index|
          if Photo.acceptable_upload?(file)
            photo = subcategory.photos.create!(colspan: 1, position: next_position + index)
            photo.image.attach(file)
          else
            rejected << file.original_filename
          end
        end

        flash[:alert] = "Fichier(s) ignoré(s) (type ou poids invalide) : #{rejected.join(', ')}" if rejected.any?
      end
  end
end
