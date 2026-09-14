require "application_system_test_case"

class SubcategoriesDeletionTest < ApplicationSystemTestCase
  setup do
    @category = Category.create!(name: "Concerts")
    @subcategory = Subcategory.create!(
      name: "Jimmy Set",
      description: "Concert du 12 mars",
      category: @category
    )
  end

  test "deleting a subcategory from its category page removes it" do
    visit category_path(@category)
    assert_text @subcategory.name

    accept_confirm do
      find("a.btn-icon i.fa-trash").click
    end

    assert_no_text @subcategory.name
    assert_not Subcategory.exists?(@subcategory.id)
  end
end
