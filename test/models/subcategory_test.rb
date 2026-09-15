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
end
