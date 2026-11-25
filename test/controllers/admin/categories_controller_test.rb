require "test_helper"

class Admin::CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @category = Category.create!(name: "Concerts")
  end

  test "reorder updates position for each category according to submitted order" do
    sign_in_as @user
    other = Category.create!(name: "Mariages")

    patch reorder_admin_categories_path, params: { category_ids: [other.id, @category.id] }

    assert_response :success
    assert_equal 0, other.reload.position
    assert_equal 1, @category.reload.position
  end

  test "index lists categories in position order" do
    other = Category.create!(name: "Mariages")
    other.update_column(:position, @category.position - 1)

    sign_in_as @user
    get admin_categories_path

    names = css_select(".admin-category-card-name").map(&:text)
    assert_equal ["Mariages", "Concerts"], names
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

  test "show displays an accessible draft badge for a draft subcategory" do
    Subcategory.create!(name: "Boiler Room", description: "Session live", category: @category, status: "draft")
    sign_in_as @user
    get admin_category_path(@category)
    assert_select ".admin-badge.admin-badge-warning", text: "Statut : Brouillon"
  end

  test "show lists subcategories in position order" do
    first = Subcategory.create!(name: "Premiere", category: @category)
    second = Subcategory.create!(name: "Deuxieme", category: @category)
    second.update_column(:position, -1)

    sign_in_as @user
    get admin_category_path(@category)

    names = css_select(".admin-subcategory-card-name").map(&:text)
    assert_equal ["Deuxieme", "Premiere"], names
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

  test "show pluralizes photo and sous-catégorie counts correctly (bug : pluralize sans plural: explicite ne fonctionne pas en locale :fr)" do
    subcategory = Subcategory.create!(name: "Boiler Room", category: @category)
    2.times do |i|
      photo = Photo.create!(subcategory: subcategory, colspan: 1, position: i)
      photo.image.attach(
        io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
        filename: "test_photo.png",
        content_type: "image/png"
      )
    end
    Subcategory.create!(name: "Autre", category: @category)

    sign_in_as @user
    get admin_category_path(@category)

    assert_select ".admin-category-head-meta", text: /2 sous-catégories/
    assert_select ".admin-subcategory-card-count", text: "2 photos"
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

  test "edit form displays the cover filename and a compact replace link" do
    sign_in_as @user
    @category.cover.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "test_photo.png",
      content_type: "image/png"
    )

    get edit_admin_category_path(@category)

    assert_select "label[for='category_cover']", text: "Remplacer l'image"
    assert_select ".admin-form-cover-filename", text: "test_photo.png"
  end

  test "create with the brouillon button creates a draft category" do
    sign_in_as @user
    post admin_categories_path, params: { category: { name: "Portraits", status: "draft" } }
    assert Category.find_by(name: "Portraits").draft?
  end

  test "create always drafts a brand-new category even via the publier button, since it has no subcategory yet" do
    sign_in_as @user
    post admin_categories_path, params: { category: { name: "Portraits", status: "published" } }
    assert Category.find_by(name: "Portraits").draft?
  end

  test "update keeps a category published once it has a cover and a subcategory" do
    sign_in_as @user
    @category.subcategories.create!(name: "Boiler Room")

    patch admin_category_path(@category), params: {
      category: {
        name: @category.name,
        status: "published",
        cover: fixture_file_upload("test_photo.png", "image/png")
      }
    }

    assert @category.reload.published?
  end

  test "update forces a category back to draft when it has no subcategory left" do
    sign_in_as @user
    @category.cover.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "test_photo.png",
      content_type: "image/png"
    )
    # @category (setup) est déjà publiée par défaut et n'a aucune sous-catégorie

    patch admin_category_path(@category), params: { category: { name: @category.name, status: "published" } }

    assert @category.reload.draft?
  end

  test "show displays an accessible draft badge for a draft category" do
    @category.update!(status: "draft")
    sign_in_as @user
    get admin_category_path(@category)
    assert_select ".admin-badge.admin-badge-warning", text: "Statut : Brouillon"
  end
end
