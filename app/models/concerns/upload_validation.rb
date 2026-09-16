module UploadValidation
  extend ActiveSupport::Concern

  ALLOWED_CONTENT_TYPES = %w[image/jpeg image/png image/webp image/heic].freeze
  MAX_UPLOAD_SIZE = 10.megabytes # Cloudinary refuse tout fichier au-delà (confirmé par CloudinaryException)

  class_methods do
    # Pré-check avant .attach : évite d'uploader un fichier invalide vers Cloudinary
    def acceptable_upload?(file)
      return false if file.size > MAX_UPLOAD_SIZE

      ALLOWED_CONTENT_TYPES.include?(real_content_type(file))
    end

    # Sniffe le type réel via les octets du fichier (Marcel), pas l'en-tête déclaré
    def real_content_type(file)
      type = Marcel::MimeType.for(file, name: file.try(:original_filename))
      file.rewind if file.respond_to?(:rewind)
      type
    end
  end
end
