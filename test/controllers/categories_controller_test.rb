require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(name: "Concerts")
  end

  test "index is accessible without authentication" do
    get root_path
    assert_response :success
  end

  test "show is accessible without authentication" do
    get category_path(@category)
    assert_response :success
  end

  test "index displays a link to the about page in the navigation" do
    get root_path
    assert_select "a[href='#{about_path}']"
  end

  test "index displays exactly one link per category, correctly nested" do
    get root_path
    assert_select "a[href='#{category_path(@category)}']", count: 1
  end

  test "layout does not duplicate the <html> root tag" do
    get root_path
    assert_equal 1, response.body.scan("<html").size
  end

  test "index has a single top-level heading for the page" do
    get root_path
    assert_select "h1", count: 1
  end

  test "subcategory description is rendered as text, not as a heading" do
    subcategory = Subcategory.create!(name: "Portugal", description: "Été 2024", category: @category)
    get category_path(@category)
    assert_select "h3", count: 0
    assert_select "p", text: subcategory.description
  end
end
