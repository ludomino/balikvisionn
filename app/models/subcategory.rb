class Subcategory < ApplicationRecord
  belongs_to :category

  # Avant : has_many_attached :photos (pas de métadonnée par photo)
  # Après : vrais enregistrements Photo, triés, supprimés en cascade
  has_many :photos, -> { order(:position) }, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
end
