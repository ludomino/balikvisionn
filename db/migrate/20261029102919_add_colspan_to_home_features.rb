class AddColspanToHomeFeatures < ActiveRecord::Migration[8.1]
  def change
    add_column :home_features, :colspan, :integer, default: 1, null: false
  end
end
