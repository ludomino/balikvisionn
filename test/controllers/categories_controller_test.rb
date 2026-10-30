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

  test "show has a single top-level heading with the category name" do
    get category_path(@category)
    assert_select "h1", text: @category.name, count: 1
  end

  test "show displays a card linking to each published subcategory" do
    subcategory = Subcategory.create!(name: "Portugal", category: @category, status: "published")
    get category_path(@category)
    assert_select "a[href='#{category_subcategory_path(@category, subcategory)}']", count: 1
  end

  test "show does not display draft subcategories" do
    Subcategory.create!(name: "Brouillon en cours", category: @category, status: "draft")
    get category_path(@category)
    assert_select ".card-category", count: 0
  end
end
