class Photo < ApplicationRecord
  # Remplace has_many_attached :photos sur Subcategory
  belongs_to :subcategory

  # Chaque photo a sa propre pièce jointe
  has_one_attached :image

  # Mosaïque : 1, 2 ou 3 colonnes (Axe 3)
  validates :colspan, inclusion: { in: 1..3 }
end
