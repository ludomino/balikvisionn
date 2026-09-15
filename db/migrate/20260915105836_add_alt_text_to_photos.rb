class AddAltTextToPhotos < ActiveRecord::Migration[8.1]
  def change
    add_column :photos, :alt_text, :string
  end
end
