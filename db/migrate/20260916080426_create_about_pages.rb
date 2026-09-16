class CreateAboutPages < ActiveRecord::Migration[8.1]
  def change
    create_table :about_pages do |t|
      t.text :biography

      t.timestamps
    end
  end
end
