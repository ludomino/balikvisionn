require "test_helper"

class Admin::CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @category = Category.create!(name: "Concerts")
  end

  test "new redirects to login when not authenticated" do
    get new_admin_category_path
    assert_redirected_to new_session_path
  end

  test "new is accessible when authenticated" do
    sign_in_as @user
    get new_admin_category_path
    assert_response :success
  end

  test "create redirects to login when not authenticated" do
    assert_no_difference "Category.count" do
      post admin_categories_path, params: { category: { name: "Portraits" } }
    end
    assert_redirected_to new_session_path
  end

  test "create succeeds when authenticated" do
    sign_in_as @user
    assert_difference "Category.count", 1 do
      post admin_categories_path, params: { category: { name: "Portraits" } }
    end
  end

  test "destroy redirects to login when not authenticated" do
    assert_no_difference "Category.count" do
      delete admin_category_path(@category)
    end
    assert_redirected_to new_session_path
  end

  test "destroy succeeds when authenticated" do
    sign_in_as @user
    assert_difference "Category.count", -1 do
      delete admin_category_path(@category)
    end
  end

  test "index displays a link to edit the about page" do
    sign_in_as @user

    get admin_categories_path

    assert_select "a[href='#{edit_admin_about_page_path}']"
  end

    test "show redirects to login when not authenticated" do
    get admin_category_path(@category)
    assert_redirected_to new_session_path
  end

  test "show is accessible when authenticated" do
    sign_in_as @user
    get admin_category_path(@category)
    assert_response :success
  end

  test "show displays a missing-cover badge when the category has no cover" do
    sign_in_as @user
    get admin_category_path(@category)
    assert_select ".admin-badge-warning", text: "Sans couverture"
  end

  test "show does not display the missing-cover badge once a cover is attached" do
    @category.cover.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "test_photo.png",
      content_type: "image/png"
    )
    sign_in_as @user
    get admin_category_path(@category)
    assert_select ".admin-badge-warning", false
  end

  test "show lists subcategories with their photo count" do
    subcategory = Subcategory.create!(name: "Boiler Room", description: "Session live", category: @category)
    photo = Photo.create!(subcategory: subcategory, colspan: 1, position: 0)
    photo.image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "test_photo.png",
      content_type: "image/png"
    )

    sign_in_as @user
    get admin_category_path(@category)

    assert_select ".admin-subcategory-card-name", text: "Boiler Room"
    assert_select ".admin-subcategory-card-count", text: "1 photo"
  end

  test "index displays a missing-cover badge for categories without a cover" do
    sign_in_as @user
    get admin_root_path
    assert_select ".admin-badge-warning", text: "Sans couverture"
  end

  test "edit is accessible when authenticated" do
    sign_in_as @user
    get edit_admin_category_path(@category)
    assert_response :success
  end

  test "new displays the admin form" do
    sign_in_as @user
    get new_admin_category_path
    assert_select ".admin-form-title", text: "Nouvelle catégorie"
  end

  test "edit displays the admin form with the category name prefilled" do
    sign_in_as @user
    get edit_admin_category_path(@category)
    assert_select ".admin-form-title", text: "Modifier la catégorie"
    assert_select "input[name='category[name]'][value='Concerts']"
  end
end
