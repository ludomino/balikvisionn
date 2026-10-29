class CreateHomeFeatures < ActiveRecord::Migration[8.1]
  def change
    create_table :home_features do |t|
      t.references :featurable, polymorphic: true, null: false, index: { unique: true }
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :home_features, :position
  end
end
