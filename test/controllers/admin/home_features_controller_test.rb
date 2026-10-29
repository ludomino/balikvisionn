require "test_helper"

class Admin::HomeFeaturesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @category = Category.create!(name: "Concerts")
    @subcategory = Subcategory.create!(
      name: "Jimmy Set",
      description: "Concert du 12 mars",
      category: @category
    )
    @photo = Photo.create!(subcategory: @subcategory, colspan: 1, position: 0)
  end

  test "create adds a category to the home favorites" do
    sign_in_as @user

    post admin_category_home_feature_path(@category)

    assert @category.reload.home_feature.present?
  end

  test "destroy removes a category from the home favorites" do
    sign_in_as @user
    @category.create_home_feature!

    delete admin_category_home_feature_path(@category)

    assert_nil @category.reload.home_feature
  end

  test "create adds a photo to the home favorites" do
    sign_in_as @user

    post admin_category_subcategory_photo_home_feature_path(@category, @subcategory, @photo)

    assert @photo.reload.home_feature.present?
  end

  test "destroy removes a photo from the home favorites" do
    sign_in_as @user
    @photo.create_home_feature!

    delete admin_category_subcategory_photo_home_feature_path(@category, @subcategory, @photo)

    assert_nil @photo.reload.home_feature
  end

  test "create redirects to login when not authenticated" do
    post admin_category_home_feature_path(@category)

    assert_redirected_to new_session_path
  end

  test "create adds a subcategory to the home favorites" do
    sign_in_as @user

    post admin_category_subcategory_home_feature_path(@category, @subcategory)

    assert @subcategory.reload.home_feature.present?
  end

  test "destroy removes a subcategory from the home favorites" do
    sign_in_as @user
    @subcategory.create_home_feature!

    delete admin_category_subcategory_home_feature_path(@category, @subcategory)

    assert_nil @subcategory.reload.home_feature
  end

  test "index lists all home features" do
    sign_in_as @user
    @category.create_home_feature!
    @photo.create_home_feature!

    get admin_home_features_path

    assert_response :success
    assert_select ".admin-mosaic-card", count: 2
  end

  test "destroy removes a home feature by id" do
    sign_in_as @user
    home_feature = @category.create_home_feature!

    delete admin_home_feature_path(home_feature)

    assert_nil @category.reload.home_feature
  end

  test "reorder updates position for each home feature according to submitted order" do
    sign_in_as @user
    first = @category.create_home_feature!
    second = @photo.create_home_feature!

    patch reorder_admin_home_features_path, params: { home_feature_ids: [second.id, first.id] }

    assert_response :success
    assert_equal 0, second.reload.position
    assert_equal 1, first.reload.position
  end

  test "colspan updates the home feature size and redirects to the index" do
    sign_in_as @user
    home_feature = @category.create_home_feature!

    patch colspan_admin_home_feature_path(home_feature, colspan: 2)

    assert_redirected_to admin_home_features_path
    assert_equal 2, home_feature.reload.colspan
  end
end
