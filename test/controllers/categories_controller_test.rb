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
    assert_select ".accueil-photos a[href='#{category_path(@category)}']", count: 1
  end

  test "show is accessible without authentication" do
    get category_path(@category)
    assert_response :success
  end

  test "show has a single top-level heading with the category name" do
    get category_path(@category)
    assert_select "h1", text: @category.name, count: 1
  end

  test "show displays a card linking to each published subcategory" do
    subcategory = Subcategory.create!(name: "Portugal", category: @category, status: "published")
    get category_path(@category)
    assert_select ".subcategories-grid a[href='#{category_subcategory_path(@category, subcategory)}']", count: 1
  end

  test "sidebar lists every category with its published subcategories, and links to each" do
    subcategory = Subcategory.create!(name: "Portugal", category: @category, status: "published")
    Subcategory.create!(name: "Brouillon", category: @category, status: "draft")
    get category_path(@category)

    assert_select ".sidebar-category-title", text: @category.name
    assert_select ".sidebar a[href='#{category_subcategory_path(@category, subcategory)}']", count: 1
    assert_select ".sidebar a", text: "Brouillon", count: 0
  end

  test "sidebar links to each category" do
    get category_path(@category)
    assert_select ".sidebar-category-title a[href='#{category_path(@category)}']", count: 1
  end

  test "sidebar includes the about link and social links" do
    get categories_path
    assert_select ".sidebar a[href='#{about_path}']"
    assert_select ".sidebar-socials .lien-icone", count: 3
  end

  test "sidebar links to the categories index, marked current only there" do
    get categories_path
    assert_select ".sidebar a[href='#{categories_path}'][aria-current='page']", count: 1

    get category_path(@category)
    assert_select ".sidebar a[href='#{categories_path}']", count: 1
    assert_select ".sidebar a[href='#{categories_path}'][aria-current]", count: 0
  end

  test "show does not display draft subcategories" do
    Subcategory.create!(name: "Brouillon en cours", category: @category, status: "draft")
    get category_path(@category)
    assert_select ".card-category", count: 0
  end

  test "index excludes draft categories" do
    draft = Category.create!(name: "Brouillon", status: "draft")
    get categories_path
    assert_select ".accueil-photos a[href='#{category_path(draft)}']", count: 0
  end

  test "show renders a 404 for a draft category accessed directly" do
    draft = Category.create!(name: "Brouillon", status: "draft")
    get category_path(draft)
    assert_response :not_found
  end
end
