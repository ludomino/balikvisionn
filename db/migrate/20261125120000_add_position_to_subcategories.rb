class AddPositionToSubcategories < ActiveRecord::Migration[8.1]
  def up
    add_column :subcategories, :position, :integer, null: false, default: 0
    add_index :subcategories, [:category_id, :position]

    Subcategory.reset_column_information
    Subcategory.all.group_by(&:category_id).each_value do |subcategories|
      subcategories.sort_by(&:id).each_with_index do |subcategory, index|
        subcategory.update_column(:position, index)
      end
    end
  end

  def down
    remove_index :subcategories, [:category_id, :position]
    remove_column :subcategories, :position
  end
end
