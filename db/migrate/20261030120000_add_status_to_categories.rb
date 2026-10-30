class AddStatusToCategories < ActiveRecord::Migration[8.1]
  def change
    # Contrairement à Subcategory (default: "draft"), on part de "published" :
    # les catégories existantes sont déjà en ligne (recette client en cours sur
    # la préprod) et ne doivent pas disparaître avec cette migration. Une
    # catégorie peut quand même être créée en brouillon explicitement depuis
    # l'admin (bouton dédié, comme pour les sous-catégories).
    add_column :categories, :status, :string, null: false, default: "published"
  end
end
