class Subcategory < ApplicationRecord
  belongs_to :category

  # Avant : has_many_attached :photos (pas de métadonnée par photo)
  # Après : vrais enregistrements Photo, triés, supprimés en cascade
  has_many :photos, -> { order(:position) }, dependent: :destroy

  # Édition d'alt_text depuis le formulaire ; reject_if bloque toute création
  # de Photo via ce canal (seul attach_photos peut en créer)
  accepts_nested_attributes_for :photos, reject_if: proc { |attrs| attrs["id"].blank? }

  validates :name, presence: true
  validates :description, presence: true
end
