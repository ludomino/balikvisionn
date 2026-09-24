require "application_system_test_case"

class ResponsiveTest < ApplicationSystemTestCase
  setup do
    6.times { |i| Category.create!(name: "Catégorie #{i}") }
  end

  test "la grille de catégories est côte à côte en desktop et empilée sous 640px" do
    visit root_path

    page.driver.browser.manage.window.resize_to(1400, 900)
    cards = all(".card-category")
    assert_equal cards[0].native.rect.y, cards[1].native.rect.y,
      "en desktop, les 2 premières cards devraient être sur la même ligne"

    page.driver.browser.manage.window.resize_to(390, 900)
    cards = all(".card-category")
    assert cards[1].native.rect.y > cards[0].native.rect.y,
      "sous 640px, les cards devraient être empilées verticalement"
  ensure
    page.driver.browser.manage.window.resize_to(1400, 1400)
  end

  test "le libellé de catégorie reste visible sans survol possible (tactile)" do
    Capybara.using_driver(:selenium_chrome_mobile) do
      visit root_path
      opacity = page.evaluate_script(
        "getComputedStyle(document.querySelector('.card-category-text')).opacity"
      )
      assert_equal "1", opacity,
        "le libellé doit être visible en permanence sur un appareil sans survol (@media (hover: none))"
    end
  end
end
