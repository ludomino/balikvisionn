require "application_system_test_case"

class SubcategoriesDeletionTest < ApplicationSystemTestCase
  setup do
    @user = User.create!(email_address: "admin@example.com", password: "password")
    @category = Category.create!(name: "Concerts")
    @subcategory = Subcategory.create!(
      name: "Jimmy Set",
      description: "Concert du 12 mars",
      category: @category
    )
  end

  test "deleting a subcategory from the admin category page removes it" do
    visit new_session_path
    fill_in "Adresse email", with: @user.email_address
    fill_in "Mot de passe", with: "password"
    click_button "Se connecter"

    assert_current_path root_path, ignore_query: true

    visit admin_category_path(@category)
    assert_text(/#{Regexp.escape(@subcategory.name)}/i)

    accept_confirm do
      find("a.btn-icon i.fa-trash").click
    end

    assert_no_text(/#{Regexp.escape(@subcategory.name)}/i)
    assert_not Subcategory.exists?(@subcategory.id)
  end
end
