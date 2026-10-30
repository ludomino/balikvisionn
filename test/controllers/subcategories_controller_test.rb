require "test_helper"

class SubcategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(name: "Concerts")
    @subcategory = Subcategory.create!(name: "Portugal", description: "Été 2024", category: @category, status: "published")
  end

  test "show is accessible without authentication" do
    get category_subcategory_path(@category, @subcategory)
    assert_response :success
  end

  test "show renders a 404 for a draft subcategory accessed directly" do
    draft = Subcategory.create!(name: "Brouillon", category: @category, status: "draft")
    get category_subcategory_path(@category, draft)
    assert_response :not_found
  end

  test "show displays the subcategory description as text, not as a heading" do
    get category_subcategory_path(@category, @subcategory)
    assert_select "h3", count: 0
    assert_select "p", text: @subcategory.description
  end

  test "show displays one tile per photo" do
    2.times { |i| @subcategory.photos.create!(colspan: 1, position: i) }
    get category_subcategory_path(@category, @subcategory)
    assert_select ".mosaic-photo", count: 2
  end

  test "sidebar marks the current subcategory with aria-current and no other" do
    other = @category.subcategories.create!(name: "Maroc", status: "published")
    get category_subcategory_path(@category, @subcategory)

    assert_select ".sidebar a[href='#{category_subcategory_path(@category, @subcategory)}'][aria-current='page']", count: 1
    assert_select ".sidebar a[href='#{category_subcategory_path(@category, other)}'][aria-current]", count: 0
  end

  test "show renders a 404 when the parent category is a draft, even if the subcategory itself is published" do
    draft_category = Category.create!(name: "Brouillon", status: "draft")
    subcategory = draft_category.subcategories.create!(name: "Maroc", status: "published")
    get category_subcategory_path(draft_category, subcategory)
    assert_response :not_found
  end
end
