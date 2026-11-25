class Subcategory < ApplicationRecord
  belongs_to :category

  # Avant : has_many_attached :photos (pas de métadonnée par photo)
  # Après : vrais enregistrements Photo, triés, supprimés en cascade
  has_many :photos, -> { order(:position) }, dependent: :destroy
  has_one :home_feature, as: :featurable, dependent: :destroy

  enum :status, { draft: "draft", published: "published" }, default: :draft

  before_validation :assign_position, on: :create

  # Édition d'alt_text depuis le formulaire ; reject_if bloque toute création
  # de Photo via ce canal (seul attach_photos peut en créer)
  accepts_nested_attributes_for :photos, reject_if: proc { |attrs| attrs["id"].blank? }

  validates :name, presence: true
  # validates :description, presence: true
  has_one_attached :cover

  include OrientationTrackable
  tracks_orientation_via :cover, refresh: true

  def missing_cover?
    !cover.attached?
  end

  # Retour client (25/11) : une sous-categorie publiee sans couverture et/ou
  # sans aucune photo s'affiche vide/cassee cote public (tuile grise, page
  # mosaique "Aucune photo"). On la repasse donc automatiquement en
  # brouillon tant que l'un des deux manque -- jamais l'inverse (on ne
  # republie jamais tout seul, ca reste une decision admin). Appele
  # explicitement depuis les controleurs plutot qu'en callback automatique :
  # a la creation, attach_photos (SubcategoriesController) tourne APRES le
  # save initial, donc un before_save/after_save verrait toujours 0 photo
  # meme quand des fichiers sont envoyes dans le meme formulaire.
  def enforce_draft_unless_content!
    return unless published?

    update!(status: :draft) if missing_cover? || photos.none?
  end

  private

  # Même pattern que HomeFeature#assign_position : position auto-assignée à
  # la création, scopée par catégorie (pilote l'ordre d'affichage admin + public).
  def assign_position
    self.position = (category.subcategories.maximum(:position) || -1) + 1
  end
end
