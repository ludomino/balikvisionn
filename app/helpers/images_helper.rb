module ImagesHelper
  # image_tag Cloudinary : qualité/format auto + lazy loading
  # Avant : pas de protection / Après : option "protected" ajoute anti-clic-droit + anti-glisser, activée uniquement au cas par cas
  def cloudinary_image_tag(attachment, alt:, protected: false, **options)
    return unless attachment.attached?

    html_options = { alt: alt, loading: "lazy" }
    html_options.merge!(draggable: false, oncontextmenu: "return false;") if protected

    image_tag attachment.url(quality: :auto, fetch_format: :auto, **options), **html_options
  end
end
