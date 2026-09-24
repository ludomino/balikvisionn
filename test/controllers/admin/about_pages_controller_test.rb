require "test_helper"

class Admin::AboutPagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "edit requires authentication" do
    get edit_admin_about_page_path
    assert_redirected_to new_session_path
  end

  test "update saves the biography" do
    sign_in_as @user

    patch admin_about_page_path, params: { about_page: { biography: "Nouvelle bio." } }

    assert_redirected_to edit_admin_about_page_path
    assert_equal "Nouvelle bio.", AboutPage.instance.reload.biography
  end

  test "edit renders the form when authenticated" do
    sign_in_as @user

    get edit_admin_about_page_path

    assert_response :success
  end

  test "update rejects an invalid photo without crashing" do
    sign_in_as @user

    patch admin_about_page_path, params: {
      about_page: {
        biography: "Bio",
        photo: fixture_file_upload("fake.txt", "text/plain")
      }
    }

    assert_response :unprocessable_entity
  end

  test "edit displays the admin form" do
    sign_in_as @user
    get edit_admin_about_page_path
    assert_select ".admin-form-title", text: "Modifier la page À propos"
  end
end
