class Subcategory < ApplicationRecord
  belongs_to :category

  has_many_attached :photos

  validates :name, presence: true
  validates :description, presence: true
end
