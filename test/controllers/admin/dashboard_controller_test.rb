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
end
