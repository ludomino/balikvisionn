class AddOrientationDataToSubcategories < ActiveRecord::Migration[7.0]
  def change
    add_column :subcategories, :orientation_data, :json
  end
end
