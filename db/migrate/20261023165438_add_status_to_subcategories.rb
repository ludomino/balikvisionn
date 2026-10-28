class AddStatusToSubcategories < ActiveRecord::Migration[8.1]
  def change
    add_column :subcategories, :status, :string, null: false, default: "draft"
  end
end
