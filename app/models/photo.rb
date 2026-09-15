class Photo < ApplicationRecord
  # Remplace has_many_attached :photos sur Subcategory
  belongs_to :subcategory

  # Chaque photo a sa propre pièce jointe
  has_one_attached :image

  # Mosaïque : 1, 2 ou 3 colonnes (Axe 3)
  validates :colspan, inclusion: { in: 1..3 }

  # Types réellement acceptés (pas ce que le navigateur prétend envoyer)
  ALLOWED_CONTENT_TYPES = %w[image/jpeg image/png image/webp image/heic].freeze
  MAX_UPLOAD_SIZE = 20.megabytes

  # Pré-check avant .attach : évite d'uploader un fichier invalide vers Cloudinary
  def self.acceptable_upload?(file)
    return false if file.size > MAX_UPLOAD_SIZE

    ALLOWED_CONTENT_TYPES.include?(real_content_type(file))
  end

  # Sniffe le type réel via les octets du fichier (Marcel), pas l'en-tête déclaré
  def self.real_content_type(file)
    type = Marcel::MimeType.for(file, name: file.try(:original_filename))
    file.rewind if file.respond_to?(:rewind)
    type
  end

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

  private

  def swap_position_with(other)
    transaction do
      my_position = position
      update!(position: other.position)
      other.update!(position: my_position)
    end
  end
end
