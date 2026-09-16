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

  private

  def swap_position_with(other)
    transaction do
      my_position = position
      update!(position: other.position)
      other.update!(position: my_position)
    end
  end
end
