require "test_helper"

class SitemapControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(name: "Concerts")
  end

  test "is accessible without authentication" do
    get sitemap_url
    assert_response :success
  end

  test "includes published subcategories, excludes drafts" do
    published = Subcategory.create!(name: "Portugal", category: @category, status: "published")
    draft = Subcategory.create!(name: "Brouillon", category: @category, status: "draft")

    get sitemap_url

    assert_includes response.body, category_subcategory_url(@category, published)
    assert_not_includes response.body, category_subcategory_url(@category, draft)
  end

  test "includes published categories, excludes drafts" do
    published = Category.create!(name: "Portraits", status: "published")
    draft = Category.create!(name: "Brouillon", status: "draft")

    get sitemap_url

    assert_includes response.body, category_url(published)
    assert_not_includes response.body, category_url(draft)
  end
end
