module ImagesHelper
  # image_tag Cloudinary : qualité/format auto + lazy loading
  def cloudinary_image_tag(attachment, alt:, **options)
    return unless attachment.attached?

    image_tag attachment.url(quality: :auto, fetch_format: :auto, **options), alt: alt, loading: "lazy"
  end
end
