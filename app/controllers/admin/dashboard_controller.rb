module Admin
  class DashboardController < Admin::BaseController
    def index
      @categories = Category.with_attached_cover.includes(subcategories: :photos)
      @category_count = @categories.size
      @subcategory_count = @categories.sum { |c| c.subcategories.size }
      @photo_count = @categories.sum { |c| c.subcategories.sum { |s| s.photos.size } }
      @categories_missing_cover = @categories.select(&:missing_cover?)
      @draft_subcategories = Subcategory.draft.includes(:category).order(:name)
      @draft_categories = Category.draft.order(:name)
    end
  end
end
