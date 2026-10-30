require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]

    def system_sign_in_as(user)
    visit new_session_path
    fill_in "Adresse email", with: user.email_address
    fill_in "Mot de passe", with: "password"
    click_button "Se connecter"
    assert_current_path admin_root_path # attend la fin de la navigation Turbo avant de continuer
  end

  # Capybara met en cache UNE session par pilote (:selenium_chrome_mobile
  # compris), partagée entre toutes les méthodes de test qui l'utilisent —
  # y compris d'un fichier à l'autre (sidebar_test.rb ET responsive_test.rb
  # l'utilisent tous les deux). Un nom de session unique à chaque appel
  # force une fenêtre de navigateur neuve à chaque fois, pour qu'aucun état
  # (focus, overflow, classes CSS) ne puisse fuiter d'un test au suivant.
  def using_mobile_driver(&block)
    Capybara.using_session("mobile-#{SecureRandom.hex(4)}") do
      Capybara.using_driver(:selenium_chrome_mobile, &block)
    end
  end
end

Capybara.register_driver :selenium_chrome_mobile do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_emulation(
    device_metrics: { width: 390, height: 844, pixelRatio: 3, touch: true },
    user_agent: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end
