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
    fill_in "Enter your email address", with: @user.email_address
    fill_in "Enter your password", with: "password"
    click_button "Sign in"

    assert_current_path root_path, ignore_query: true

    visit admin_category_path(@category)
    assert_text @subcategory.name

    accept_confirm do
      find("a.btn-icon i.fa-trash").click
    end

    assert_no_text @subcategory.name
    assert_not Subcategory.exists?(@subcategory.id)
  end
end
