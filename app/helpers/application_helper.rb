module ApplicationHelper
  # Catégories + sous-catégories publiées pour le menu latéral (Axe 8).
  def sidebar_categories
    @sidebar_categories ||= Category.includes(:subcategories).all
  end
end
