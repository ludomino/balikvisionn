class CreatePhotos < ActiveRecord::Migration[7.0]
  def change
    create_table :photos do |t|
      t.references :subcategory, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      t.integer :colspan, null: false, default: 1

      t.timestamps
    end

    add_index :photos, [:subcategory_id, :position]
  end
end
