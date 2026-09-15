require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]

  # sign_in_as (test/test_helpers) ne marche que pour les tests d'intégration :
  # un test système pilote un vrai navigateur avec son propre cookie jar
  def system_sign_in_as(user)
    visit new_session_path
    fill_in "Email address", with: user.email_address
    fill_in "Password", with: "password"
    click_button "Sign in"
    assert_current_path root_path # attend la fin de la navigation Turbo avant de continuer
  end
end
