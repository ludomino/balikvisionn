class SubcategoriesController < ApplicationController

  def destroy
    @category = Category.find(params[:category_id])
    @subcategory = @category.subcategories.find(params[:id])
    @subcategory.destroy
    redirect_to category_path(@category), notice: 'Subcategory was successfully destroyed.'
  end

  def edit
    @category = Category.find(params[:category_id])
    @subcategory = @category.subcategories.find(params[:id])
  end

  # def update
  #   @category = Category.find(params[:category_id])
  #   @subcategory = @category.subcategories.find(params[:id])

  #   if @subcategory.update(subcategory_params)
  #     redirect_to category_path(@category), notice: 'Subcategory was successfully updated.'
  #   else
  #     render :edit
  #   end
  # end

  def update
    @category = Category.find(params[:category_id])
    @subcategory = @category.subcategories.find(params[:id])

    if @subcategory.update(subcategory_params)
      # Apply Cloudinary image compression when updating
      compress_images(@subcategory.photos)

      redirect_to category_path(@category), notice: 'Subcategory was successfully updated.'
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

    @subcategory.save!
    if @subcategory.save
      redirect_to category_path(@category), notice: 'Subcategory was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

   private

  def compress_images(photos)
    # Iterate through each photo and apply Cloudinary image compression
    photos.each do |photo|
      Cloudinary::Uploader.upload(photo.path, public_id: photo.filename_without_extension, quality: 'auto:low')
    end
  end

  def subcategory_params
    params.require(:subcategory).permit(:name, :description, photos: [])
  end
end
