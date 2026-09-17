require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  # a11y : l'erreur de connexion doit être annoncée aux lecteurs d'écran
  test "new displays a login error with an accessible alert role" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }
    follow_redirect!

    assert_select "[role=alert]", text: /incorrect/i
  end

  # a11y : chaque champ du formulaire doit avoir un label associé (for/id)
  test "new renders labels associated with their inputs" do
    get new_session_path

    assert_select "label[for=email_address]"
    assert_select "input#email_address[type=email]"
    assert_select "label[for=password]"
    assert_select "input#password[type=password]"
  end

  test "destroy" do
    sign_in_as(User.take)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end
end
