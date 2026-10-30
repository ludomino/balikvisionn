require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "index redirects to login when not authenticated" do
    get admin_root_path
    assert_redirected_to new_session_path
  end

  test "index is accessible when authenticated" do
    sign_in_as @user

    get admin_root_path

    assert_response :success
  end

  test "index displays the logout link" do
    sign_in_as @user

    get admin_root_path

    assert_select "form[action='#{session_path}'] input[name='_method'][value='delete']"
  end

  test "index displays a link to edit the about page" do
    sign_in_as @user

    get admin_root_path

    assert_select "a[href='#{edit_admin_about_page_path}']"
  end

  test "index displays a missing-cover badge for categories without a cover" do
    Category.create!(name: "Concerts")

    sign_in_as @user
    get admin_root_path
    assert_select ".admin-badge-warning", text: "Sans couverture"
  end

  test "index displays the key indicators" do
    category = Category.create!(name: "Concerts")
    Subcategory.create!(name: "Boiler Room", description: "Session live", category: category)

    sign_in_as @user
    get admin_root_path

    assert_select ".admin-stats-row .admin-stat-tile", count: 4
    assert_select ".admin-stat-value", text: "1", count: 3 # 1 catégorie, 1 sous-catégorie, 1 brouillon (statut par défaut)
    assert_select ".admin-stat-value", text: "0" # 0 photo publiée
  end

  test "index displays an alert banner listing categories without a cover" do
    category = Category.create!(name: "Concerts")

    sign_in_as @user
    get admin_root_path

    assert_select ".admin-alert-banner a[href='#{admin_category_path(category)}']", text: "Concerts"
  end

  test "index does not display the alert banner when every category has a cover" do
    category = Category.create!(name: "Concerts")
    category.cover.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "test_photo.png",
      content_type: "image/png"
    )

    sign_in_as @user
    get admin_root_path

    assert_select ".admin-alert-banner", false
  end

  test "index displays a shortcut to create a subcategory for each category" do
    category = Category.create!(name: "Concerts")

    sign_in_as @user
    get admin_root_path

    assert_select "option[value='#{new_admin_category_subcategory_path(category)}']", text: "Concerts"
  end

  test "index displays the number of draft subcategories on each category card" do
    category = Category.create!(name: "Concerts")
    Subcategory.create!(name: "Boiler Room", description: "Session live", category: category)

    sign_in_as @user
    get admin_root_path

    assert_select ".admin-category-card-count", text: /1 brouillon/
  end

  test "index does not display a draft count when all subcategories are published" do
    category = Category.create!(name: "Concerts")
    Subcategory.create!(name: "Boiler Room", description: "Session live", category: category, status: "published")

    sign_in_as @user
    get admin_root_path

    assert_select ".admin-category-card-count", text: /brouillon/, count: 0
  end

  test "index displays the drafts-in-progress section with a resume link" do
    category = Category.create!(name: "Concerts")
    subcategory = Subcategory.create!(name: "Boiler Room", description: "Session live", category: category, status: "draft")

    sign_in_as @user
    get admin_root_path

    assert_select ".admin-drafts-section" do
      assert_select ".admin-drafts-item", text: /Boiler Room/
      assert_select "a[href='#{edit_admin_category_subcategory_path(category, subcategory)}']", text: "Reprendre →"
    end
  end

  test "index hides the drafts-in-progress section when there are no drafts" do
    category = Category.create!(name: "Concerts")
    Subcategory.create!(name: "Boiler Room", description: "Session live", category: category, status: "published")

    sign_in_as @user
    get admin_root_path

    assert_select ".admin-drafts-section", false
  end

  test "index displays a shortcut to start a new draft for each category" do
    category = Category.create!(name: "Concerts")
    Subcategory.create!(name: "Autre", description: "x", category: category, status: "draft")

    sign_in_as @user
    get admin_root_path

    assert_select ".admin-drafts-section option[value='#{new_admin_category_subcategory_path(category)}']", text: "Concerts"
  end
end
