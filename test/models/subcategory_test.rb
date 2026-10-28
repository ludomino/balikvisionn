require "test_helper"

class SubcategoryTest < ActiveSupport::TestCase
  setup do
    @category = Category.create!(name: "Concerts")
    @subcategory = Subcategory.create!(name: "Jimmy Set", description: "Concert du 12 mars", category: @category)
  end

  test "photos are returned ordered by position" do
    photo_b = Photo.create!(subcategory: @subcategory, colspan: 1, position: 1)
    photo_a = Photo.create!(subcategory: @subcategory, colspan: 1, position: 0)

    assert_equal [photo_a, photo_b], @subcategory.photos.to_a
  end

  test "destroying a subcategory destroys its photos" do
    Photo.create!(subcategory: @subcategory, colspan: 1, position: 0)

    assert_difference "Photo.count", -1 do
      @subcategory.destroy
    end
  end

    test "updates alt_text on an existing photo via nested attributes" do
    photo = Photo.create!(subcategory: @subcategory, colspan: 1, position: 0)

    @subcategory.update!(photos_attributes: [{ id: photo.id, alt_text: "Concert de jazz" }])

    assert_equal "Concert de jazz", photo.reload.alt_text
  end

  test "nested photos_attributes without an id never creates a new photo" do
    assert_no_difference "Photo.count" do
      @subcategory.update!(photos_attributes: [{ alt_text: "Sans id, doit être ignoré" }])
    end
  end

  test "nouvelle sous-catégorie est en brouillon par défaut" do
    assert @subcategory.draft?
  end

  test "peut passer en publié" do
    @subcategory.published!
    assert @subcategory.published?
  end

  test "missing_cover? is true when no cover is attached" do
    assert @subcategory.missing_cover?
  end

  test "missing_cover? is false once a cover is attached" do
    @subcategory.cover.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "test_photo.png",
      content_type: "image/png"
    )
    assert_not @subcategory.missing_cover?
  end

  test "valid without a description" do
    subcategory = Subcategory.new(name: "Test", category: @category)
    assert subcategory.valid?
  end
end
