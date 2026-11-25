class Category < ApplicationRecord
  has_many :subcategories, -> { order(:position) }, dependent: :destroy
  has_one_attached :cover
  has_one :home_feature, as: :featurable, dependent: :destroy

  enum :status, { draft: "draft", published: "published" }, default: :published

  before_validation :assign_position, on: :create

  after_update :cascade_draft_to_subcategories, if: :saved_change_to_status?

  validates :name, presence: true
  # validates :cover, presence: true

  include OrientationTrackable
  tracks_orientation_via :cover, refresh: true

  def missing_cover?
    !cover.attached?
  end

  private

  # Republier la catégorie ne republie pas les sous-catégories dans l'autre
  # sens : on ne veut pas remettre en ligne du contenu volontairement laissé
  # en brouillon pour une autre raison.
  def cascade_draft_to_subcategories
    subcategories.update_all(status: "draft") if draft?
  end

  # Même pattern que HomeFeature#assign_position : position auto-assignée à
  # la création (pilote l'ordre d'affichage de la grille admin + public).
  def assign_position
    self.position = (Category.maximum(:position) || -1) + 1
  end
end
