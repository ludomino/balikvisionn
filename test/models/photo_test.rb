require "test_helper"

# TDD : décrit le modèle Photo avant qu'il n'existe
class PhotoTest < ActiveSupport::TestCase
  setup do
    @category = Category.create!(name: "Concerts")
    @subcategory = Subcategory.create!(name: "Jimmy Set", description: "Concert du 12 mars", category: @category)
  end

  test "valid with colspan 1, 2 or 3" do
    [1, 2, 3].each do |value|
      photo = Photo.new(subcategory: @subcategory, colspan: value, position: 0)
      assert photo.valid?, "colspan #{value} devrait être valide"
    end
  end

  test "invalid with colspan outside 1..3" do
    [0, 4, -1].each do |value|
      photo = Photo.new(subcategory: @subcategory, colspan: value, position: 0)
      assert_not photo.valid?, "colspan #{value} ne devrait pas être valide"
    end
  end

  test "invalid without a subcategory" do
    photo = Photo.new(colspan: 1, position: 0)
    assert_not photo.valid?
  end
end
