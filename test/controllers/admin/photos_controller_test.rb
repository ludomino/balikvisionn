require "test_helper"

class Admin::PhotosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @category = Category.create!(name: "Concerts")
    @subcategory = Subcategory.create!(name: "Jimmy Set", description: "Concert du 12 mars", category: @category)
    @photo_a = Photo.create!(subcategory: @subcategory, colspan: 1, position: 0)
    @photo_b = Photo.create!(subcategory: @subcategory, colspan: 1, position: 1)
  end

  test "move_higher requires authentication" do
    patch move_higher_admin_category_subcategory_photo_path(@category, @subcategory, @photo_b)
    assert_redirected_to new_session_path
  end

  test "move_higher swaps position and redirects to the edit page" do
    sign_in_as @user

    patch move_higher_admin_category_subcategory_photo_path(@category, @subcategory, @photo_b)

    assert_redirected_to edit_admin_category_subcategory_path(@category, @subcategory)
    assert_equal 0, @photo_b.reload.position
    assert_equal 1, @photo_a.reload.position
  end

  test "move_lower swaps position and redirects to the edit page" do
    sign_in_as @user

    patch move_lower_admin_category_subcategory_photo_path(@category, @subcategory, @photo_a)

    assert_redirected_to edit_admin_category_subcategory_path(@category, @subcategory)
    assert_equal 1, @photo_a.reload.position
    assert_equal 0, @photo_b.reload.position
  end

  test "destroy removes the photo and purges its blob" do
    sign_in_as @user
    blob = @photo_a.image.blob rescue nil

    perform_enqueued_jobs do
      assert_difference "Photo.count", -1 do
        delete admin_category_subcategory_photo_path(@category, @subcategory, @photo_a)
      end
    end

    assert_redirected_to edit_admin_category_subcategory_path(@category, @subcategory)
  end

  test "reorder updates position for each photo according to submitted order" do
    sign_in_as @user

    patch reorder_admin_category_subcategory_photos_path(@category, @subcategory), params: {
      photo_ids: [@photo_b.id, @photo_a.id]
    }

    assert_response :success
    assert_equal 0, @photo_b.reload.position
    assert_equal 1, @photo_a.reload.position
  end
end
