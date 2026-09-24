require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "missing_cover? is true when no cover is attached" do
    category = Category.create!(name: "Concerts")
    assert category.missing_cover?
  end

  test "missing_cover? is false once a cover is attached" do
    category = Category.create!(name: "Concerts")
    category.cover.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "test_photo.png",
      content_type: "image/png"
    )
    assert_not category.missing_cover?
  end
end
