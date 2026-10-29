require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(name: "Concerts")
  end

  test "index is accessible without authentication" do
    get root_path
    assert_response :success
  end

  test "displays a link to the about page in the navigation" do
    get root_path
    assert_select "a[href='#{about_path}']"
  end

  test "layout does not duplicate the <html> root tag" do
    get root_path
    assert_equal 1, response.body.scan("<html").size
  end

  test "has a single top-level heading for the page" do
    get root_path
    assert_select "h1", count: 1
  end

  test "displays nothing when no home feature is set" do
    get root_path
    assert_select ".home-feature-tile", count: 0
  end

  test "links a featured category to its own page" do
    HomeFeature.create!(featurable: @category)
    get root_path
    assert_select "a.home-feature-tile[href='#{category_path(@category)}']", count: 1
  end

  test "links a featured subcategory to its parent category's page" do
    subcategory = Subcategory.create!(name: "Portugal", category: @category, status: "published")
    HomeFeature.create!(featurable: subcategory)
    get root_path
    assert_select "a.home-feature-tile[href='#{category_path(@category)}']", count: 1
  end

  test "links a featured photo to its subcategory's parent category page" do
    subcategory = Subcategory.create!(name: "Portugal", category: @category, status: "published")
    photo = Photo.create!(subcategory: subcategory, colspan: 1, position: 0)
    HomeFeature.create!(featurable: photo)
    get root_path
    assert_select "a.home-feature-tile[href='#{category_path(@category)}']", count: 1
  end
end
