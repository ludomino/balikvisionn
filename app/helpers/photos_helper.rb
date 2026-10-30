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

  # Portrait : recadrée en 4:5 comme partout ailleurs sur le site.
  # Paysage : pas de recadrage — la lightbox est le seul endroit où on montre la photo
  # entière, le forcer en 4:5 couperait une bonne partie d'une photo horizontale.
  def photo_lightbox_url(photo)
    return unless photo.image.attached?

    if photo.landscape?
      photo.image.url(quality: :auto, fetch_format: :auto, width: 1600, crop: :limit)
    else
      photo.image.url(quality: :auto, fetch_format: :auto, width: 1600, aspect_ratio: "4:5", crop: :fill, gravity: :auto)
    end
  end
end
