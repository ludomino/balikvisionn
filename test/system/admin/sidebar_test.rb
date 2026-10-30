require "application_system_test_case"

class Admin::SidebarTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
  end

  test "le burger ouvre le panneau avec les 4 liens de navigation" do
    system_sign_in_as @user
    visit admin_root_path
    assert_no_selector ".admin-sidebar.is-open"

    find(".admin-topbar-burger").click
    assert_selector ".admin-sidebar.is-open"
    sleep 0.3 # laisse la transition CSS (transform 0.25s) se terminer avant d'interagir

    assert_selector ".admin-sidebar-link", text: /favoris de la home/i
    assert_selector ".admin-sidebar-link", text: /toutes les catégories/i
    assert_selector ".admin-sidebar-link", text: /brouillons en cours/i
    assert_selector ".admin-sidebar-link", text: /à propos/i
  end

  test "Échap referme le panneau" do
    system_sign_in_as @user
    visit admin_root_path
    find(".admin-topbar-burger").click
    assert_selector ".admin-sidebar.is-open"
    sleep 0.3

    find(".admin-sidebar").send_keys(:escape)
    assert_no_selector ".admin-sidebar.is-open"
  end

  test "le lien Favoris de la home mène au bon écran" do
    system_sign_in_as @user
    visit admin_root_path
    find(".admin-topbar-burger").click
    sleep 0.3

    find(".admin-sidebar-link", text: /favoris de la home/i).click
    assert_current_path admin_home_features_path
  end

  test "le lien Toutes les catégories mène au bon écran" do
    system_sign_in_as @user
    visit admin_root_path
    find(".admin-topbar-burger").click
    sleep 0.3

    find(".admin-sidebar-link", text: /toutes les catégories/i).click
    assert_current_path admin_categories_path
  end
end
