class Category < ApplicationRecord
  has_many :subcategories, dependent: :destroy
  has_one_attached :cover
  has_one :home_feature, as: :featurable, dependent: :destroy

  validates :name, presence: true
  # validates :cover, presence: true

  include OrientationTrackable
  tracks_orientation_via :cover, refresh: true

  def missing_cover?
    !cover.attached?
  end
end
