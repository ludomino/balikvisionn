class Category < ApplicationRecord
  has_many :subcategories, dependent: :destroy
  has_one_attached :cover

  validates :name, presence: true
  # validates :cover, presence: true

  def missing_cover?
    !cover.attached?
  end
end
