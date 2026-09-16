require "test_helper"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  test "valid submission sends an email and redirects to about with a notice" do
    assert_emails 1 do
      post contact_path, params: { contact: { name: "Jean", email: "jean@example.com", message: "Bonjour" } }
    end

    assert_redirected_to about_path
    assert_equal "Message envoyé, merci !", flash[:notice]
  end

  test "invalid submission does not send an email and re-renders the about page with errors" do
    assert_no_emails do
      post contact_path, params: { contact: { name: "", email: "", message: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "honeypot filled silently discards the message without sending an email" do
    # Même comportement qu'un succès pour un bot, afin de ne pas révéler la détection
    assert_no_emails do
      post contact_path, params: { contact: { name: "Bot", email: "bot@example.com", message: "spam", nickname: "http://spam.com" } }
    end

    assert_redirected_to about_path
  end
end
