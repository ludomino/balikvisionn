class AboutPage < ApplicationRecord
  include UploadValidation

  has_one_attached :photo

  # Singleton : une seule ligne pour toute la page "À propos"
  def self.instance
    first_or_create!
  end
end
