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

  test "links a featured subcategory to its own page" do
    subcategory = Subcategory.create!(name: "Portugal", category: @category, status: "published")
    HomeFeature.create!(featurable: subcategory)
    get root_path
    assert_select "a.home-feature-tile[href='#{category_subcategory_path(@category, subcategory)}']", count: 1
  end

  test "links a featured photo to its own subcategory's page" do
    subcategory = Subcategory.create!(name: "Portugal", category: @category, status: "published")
    photo = Photo.create!(subcategory: subcategory, colspan: 1, position: 0)
    HomeFeature.create!(featurable: photo)
    get root_path
    assert_select "a.home-feature-tile[href='#{category_subcategory_path(@category, subcategory)}']", count: 1
  end

  test "does not display a featured draft category" do
    draft = Category.create!(name: "Brouillon", status: "draft")
    HomeFeature.create!(featurable: draft)
    get root_path
    assert_select ".home-feature-tile", count: 0
  end

  test "does not display a featured subcategory whose parent category is a draft" do
    draft_category = Category.create!(name: "Brouillon", status: "draft")
    subcategory = draft_category.subcategories.create!(name: "Maroc", status: "published")
    HomeFeature.create!(featurable: subcategory)
    get root_path
    assert_select ".home-feature-tile", count: 0
  end

  test "does not display a featured draft subcategory even if its category is published" do
    subcategory = Subcategory.create!(name: "Brouillon", category: @category, status: "draft")
    HomeFeature.create!(featurable: subcategory)
    get root_path
    assert_select ".home-feature-tile", count: 0
  end

  test "does not display a featured photo belonging to a draft subcategory" do
    subcategory = Subcategory.create!(name: "Brouillon", category: @category, status: "draft")
    photo = Photo.create!(subcategory: subcategory, colspan: 1, position: 0)
    HomeFeature.create!(featurable: photo)
    get root_path
    assert_select ".home-feature-tile", count: 0
  end
end
