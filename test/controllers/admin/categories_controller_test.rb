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
end
