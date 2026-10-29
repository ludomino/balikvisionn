class HomeFeature < ApplicationRecord
  belongs_to :featurable, polymorphic: true
  validates :featurable_id, uniqueness: { scope: :featurable_type }
  validates :colspan, inclusion: { in: 1..3 }
  before_validation :assign_position, on: :create
  TYPE_LABELS = { "Category" => "Catégorie", "Subcategory" => "Sous-catégorie", "Photo" => "Photo" }.freeze

  def label
    featurable.is_a?(Photo) ? (featurable.title.presence || featurable.alt_text.presence || "Photo") : featurable.name
  end

  def type_label
    TYPE_LABELS.fetch(featurable_type)
  end

  def cover_attachment
    featurable.is_a?(Photo) ? featurable.image : featurable.cover
  end

  private

  def assign_position
    self.position = (HomeFeature.maximum(:position) || -1) + 1
  end
end
