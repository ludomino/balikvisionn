require "test_helper"

class SubcategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(name: "Concerts")
    @subcategory = Subcategory.create!(
      name: "Jimmy Set",
      description: "Concert du 12 mars",
      category: @category
    )
    @subcategory.photos.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "test_photo.png",
      content_type: "image/png"
    )
  end

  test "updating a subcategory succeeds without raising an error" do
    patch category_subcategory_path(@category, @subcategory), params: {
      subcategory: { name: "Nouveau nom", description: "Nouvelle description" }
    }

    assert_redirected_to category_path(@category)
    @subcategory.reload
    assert_equal "Nouveau nom", @subcategory.name
  end
end
