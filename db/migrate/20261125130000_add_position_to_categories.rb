class AddPositionToCategories < ActiveRecord::Migration[8.1]
  def up
    add_column :categories, :position, :integer, null: false, default: 0
    add_index :categories, :position

    Category.reset_column_information
    Category.order(:id).each_with_index do |category, index|
      category.update_column(:position, index)
    end
  end

  def down
    remove_index :categories, :position
    remove_column :categories, :position
  end
end
