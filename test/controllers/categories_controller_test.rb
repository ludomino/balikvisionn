require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(name: "Concerts")
  end

  test "index is accessible without authentication" do
    get categories_path
    assert_response :success
  end

  test "index displays exactly one link per category" do
    get categories_path
    assert_select "a[href='#{category_path(@category)}']", count: 1
  end

  test "show is accessible without authentication" do
    get category_path(@category)
    assert_response :success
  end

  test "subcategory description is rendered as text, not as a heading" do
    subcategory = Subcategory.create!(name: "Portugal", description: "Été 2024", category: @category, status: "published")
    get category_path(@category)
    assert_select "h3", count: 0
    assert_select "p", text: subcategory.description
  end

  test "affiche un lien d'ancre par sous-catégorie quand il y en a plusieurs" do
    portugal = Subcategory.create!(name: "Portugal", description: "Été 2024", category: @category, status: "published")
    tokyo = Subcategory.create!(name: "Tokyo", description: "Hiver 2023", category: @category, status: "published")

    get category_path(@category)

    assert_select "nav.subcategories-nav a[href='#subcategory-#{portugal.id}']", text: portugal.name
    assert_select "nav.subcategories-nav a[href='#subcategory-#{tokyo.id}']", text: tokyo.name
    assert_select "#subcategory-#{portugal.id}"
    assert_select "#subcategory-#{tokyo.id}"
  end

  test "masque la nav d'ancrage s'il n'y a qu'une seule sous-catégorie" do
    Subcategory.create!(name: "Portugal", description: "Été 2024", category: @category, status: "published")
    get category_path(@category)

    assert_select "nav.subcategories-nav", count: 0
  end

  test "does not display draft subcategories publicly" do
    Subcategory.create!(name: "Brouillon en cours", description: "Pas encore prêt", category: @category, status: "draft")

    get category_path(@category)

    assert_select "p", text: "Pas encore prêt", count: 0
  end

  test "displays published subcategories publicly" do
    Subcategory.create!(name: "Prêt", description: "Visible", category: @category, status: "published")

    get category_path(@category)

    assert_select "p", text: "Visible"
  end
end
