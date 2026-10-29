class AddDimensionsToSubcategories < ActiveRecord::Migration[8.1]
  def change
    add_column :subcategories, :width, :integer
    add_column :subcategories, :height, :integer
  end
end
