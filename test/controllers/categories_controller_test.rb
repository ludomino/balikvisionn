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
end
