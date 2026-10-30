require "application_system_test_case"

class SidebarTest < ApplicationSystemTestCase
  setup do
    @category = Category.create!(name: "Rue")
    @subcategory = Subcategory.create!(name: "Tokyo", category: @category, status: "published")
  end

  test "en desktop, la sidebar liste les catégories sans interaction" do
    visit categories_path

    assert_selector ".sidebar-category-title", text: /rue/i
    assert_selector ".sidebar-subcategory-link", text: "Tokyo"
  end

  test "en mobile, le burger ouvre le panneau et Échap le referme" do
    using_mobile_driver do
      visit categories_path
      assert_no_selector ".sidebar.is-open"

      find(".topbar-burger").click
      assert_selector ".sidebar.is-open"
      sleep 0.3 # laisse la transition CSS (transform 0.25s) se terminer avant d'interagir
      assert_selector ".sidebar-category-title", text: /rue/i

      find(".sidebar").send_keys(:escape)
      assert_no_selector ".sidebar.is-open"
    end
  end

  test "en mobile, le focus est piégé dans le panneau (Tab boucle du dernier au premier élément)" do
    using_mobile_driver do
      visit categories_path
      find(".topbar-burger").click
      assert_selector ".sidebar.is-open"
      sleep 0.3 # idem : attend la fin de la transition avant d'envoyer des touches

      first_label = find(".sidebar-close")["aria-label"]
      all(".sidebar a, .sidebar button").last.send_keys(:tab)

      assert_equal first_label, page.evaluate_script("document.activeElement.getAttribute('aria-label')")
    end
  end

  test "en mobile, fermer le panneau restitue le focus au bouton burger" do
    using_mobile_driver do
      visit categories_path
      find(".topbar-burger").click
      assert_selector ".sidebar.is-open"
      sleep 0.3 # idem : attend la fin de la transition avant de cliquer sur fermer

      find(".sidebar-close").click

      assert_equal "Ouvrir le menu", page.evaluate_script("document.activeElement.getAttribute('aria-label')")
    end
  end
end
