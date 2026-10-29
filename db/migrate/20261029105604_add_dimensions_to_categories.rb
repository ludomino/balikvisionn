class AddDimensionsToCategories < ActiveRecord::Migration[8.1]
  def change
    add_column :categories, :width, :integer
    add_column :categories, :height, :integer
  end
end
