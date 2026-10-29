module Admin
  class HomeFeaturesController < Admin::BaseController
    before_action :set_featurable, only: [:create]

    def index
      @home_features = HomeFeature.includes(:featurable).order(:position)
    end

    def create
      @featurable.create_home_feature!
      redirect_back fallback_location: admin_root_path
    end

    def destroy
      home_feature = params[:id].present? ? HomeFeature.find(params[:id]) : set_featurable.home_feature
      home_feature.destroy
      redirect_back fallback_location: admin_root_path
    end

    # Persiste le nouvel ordre après un glisser-déposer sur l'écran "Favoris de la home"
    def reorder
      params[:home_feature_ids].each_with_index do |id, index|
        HomeFeature.where(id: id).update_all(position: index)
      end
      head :ok
    end

    def colspan
      HomeFeature.find(params[:id]).update(colspan: params[:colspan])
      redirect_to admin_home_features_path
    end

    private

    # Utilisé par create (via before_action) et par destroy quand l'appel vient
    # d'une route imbriquée (ex. ★ sur la grille des catégories) plutôt que de
    # l'écran "Favoris de la home" (qui identifie le HomeFeature par son propre id)
    def set_featurable
      @featurable = if params[:photo_id].present?
        Photo.find(params[:photo_id])
      elsif params[:subcategory_id].present?
        Subcategory.find(params[:subcategory_id])
      else
        Category.find(params[:category_id])
      end
    end
  end
end
