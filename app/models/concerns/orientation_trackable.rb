# Partagé par Photo, Category et Subcategory : détecte l'orientation
# (paysage/portrait) de l'image attachée, via les dimensions renvoyées par
# l'API Cloudinary (Active Storage ne peut pas analyser les images en local,
# faute de libvips/ImageMagick).
module OrientationTrackable
  extend ActiveSupport::Concern

  class_methods do
    # attachment_name : :image pour Photo, :cover pour Category/Subcategory
    # refresh: true relance toujours la récupération à chaque sauvegarde —
    # nécessaire pour Category/Subcategory dont la couverture peut être
    # remplacée ; inutile pour Photo dont l'image ne change jamais après coup,
    # et dont le colspan est modifié très fréquemment (pas une requête
    # Cloudinary à chaque clic sur 1/2/3 !).
    def tracks_orientation_via(attachment_name, refresh: false)
      define_method(:orientation_attachment) { public_send(attachment_name) }

      guard = refresh ? -> { orientation_attachment.attached? } : -> { orientation_attachment.attached? && width.blank? }
      after_save_commit :fetch_cloudinary_dimensions, if: guard
    end
  end

  def landscape?
    width.present? && height.present? && width > height
  end

  def mosaic_crop_ratio(colspan)
    return "4:5" unless colspan > 1 && landscape?

    case colspan
    when 2 then "8:5"
    when 3 then "12:5"
    else "4:5"
    end
  end

  private

  def fetch_cloudinary_dimensions
    attachment = orientation_attachment
    return unless attachment.blob.service.respond_to?(:public_id)

    public_id = attachment.blob.service.public_id(attachment.blob.key)
    resource = Cloudinary::Api.resource(public_id)
    update_columns(width: resource["width"], height: resource["height"])
  rescue Cloudinary::Api::Error
    nil
  end
end
