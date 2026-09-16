module Admin
  class AboutPagesController < Admin::BaseController
    def edit
      @about_page = AboutPage.instance
    end

    def update
      @about_page = AboutPage.instance
      photo = about_page_params[:photo]

      if photo.present? && !AboutPage.acceptable_upload?(photo)
        @about_page.errors.add(:photo, "doit être une image valide (JPEG/PNG/WebP/HEIC), 10 Mo maximum")
        return render :edit, status: :unprocessable_entity
      end

      if @about_page.update(about_page_params)
        redirect_to edit_admin_about_page_path, notice: "Page à propos mise à jour."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def about_page_params
      params.require(:about_page).permit(:biography, :photo)
    end
  end
end
