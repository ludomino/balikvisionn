require "application_system_test_case"

class ImageProtectionTest < ApplicationSystemTestCase
  test "les photos publiques sont protégées contre le clic droit et le glisser-déposer" do
    category = Category.create!(name: "Voyages")
    subcategory = Subcategory.create!(name: "Portugal", description: "Été 2024", category: category)
    photo = subcategory.photos.build(alt_text: "Photo test", colspan: 1)
    photo.image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "test_photo.png",
      content_type: "image/png"
    )
    photo.save!

    visit category_path(category)
    img = find(".mosaic-photo img")

    assert_equal "false", img["draggable"]
    assert_equal "return false;", img["oncontextmenu"]
  end
end
