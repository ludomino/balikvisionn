class Category < ApplicationRecord
  has_many :subcategories, dependent: :destroy
  has_one_attached :cover
  has_one :home_feature, as: :featurable, dependent: :destroy

  enum :status, { draft: "draft", published: "published" }, default: :published

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
end
