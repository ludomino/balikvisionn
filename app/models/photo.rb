class Photo < ApplicationRecord
  include UploadValidation

  # Remplace has_many_attached :photos sur Subcategory
  belongs_to :subcategory

  # Chaque photo a sa propre pièce jointe
  has_one_attached :image

  # Mosaïque : 1, 2 ou 3 colonnes (Axe 3)
  validates :colspan, inclusion: { in: 1..3 }

  # Échange de position avec le voisin précédent (remonte dans la liste)
  def move_higher
    neighbor = subcategory.photos.where("position < ?", position).order(position: :desc).first
    swap_position_with(neighbor) if neighbor
  end

  # Échange de position avec le voisin suivant (descend dans la liste)
  def move_lower
    neighbor = subcategory.photos.where("position > ?", position).order(:position).first
    swap_position_with(neighbor) if neighbor
  end

  after_create_commit :fetch_cloudinary_dimensions, if: -> { image.attached? }

  def landscape?
    width.present? && height.present? && width > height
  end

  # Ratio demandé à Cloudinary pour le recadrage de la mosaïque.
  # Les tuiles 1x1 restent toujours en 4:5. Les tuiles plus grandes passent
  # en format paysage (ratio inversé, approximatif) si la photo source l'est.
  def mosaic_crop_ratio
    return "4:5" unless colspan > 1 && landscape?

    case colspan
    when 2 then "8:5"
    when 3 then "6:5"
    else "4:5"
    end
  end

  private

  def fetch_cloudinary_dimensions
    return if width.present? && height.present?

    public_id = image.blob.service.public_id(image.blob.key)
    resource = Cloudinary::Api.resource(public_id)
    update_columns(width: resource["width"], height: resource["height"])
  rescue Cloudinary::Api::Error
    nil
  end

  def swap_position_with(other)
    transaction do
      my_position = position
      update!(position: other.position)
      other.update!(position: my_position)
    end
  end
end
