module PhotosHelper
  # Avant : Cloudinary recevait toujours 1000x1000 (carré), écrasé ensuite en CSS → double recadrage
  # Après : dimensions demandées à Cloudinary = ratio réel de la case dans la mosaïque
  def photo_mosaic_dimensions(colspan)
    case colspan
    when 2 then [1000, 500]
    when 3 then [1500, 500]
    else [500, 500]
    end
  end

  # Avant : rien / Après : URL Cloudinary pleine résolution pour la lightbox (crop: :limit → jamais de recadrage, juste un plafond de largeur)
  def photo_lightbox_url(photo)
    return unless photo.image.attached?
    photo.image.url(quality: :auto, fetch_format: :auto, width: 1600, crop: :limit)
  end
end
