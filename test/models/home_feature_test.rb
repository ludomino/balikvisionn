require "test_helper"

class HomeFeatureTest < ActiveSupport::TestCase
  setup do
    @category = Category.create!(name: "Concerts")
  end

  test "valid with a category as featurable" do
    home_feature = HomeFeature.new(featurable: @category)
    assert home_feature.valid?
  end

  test "assigns position automatically on create" do
    other_category = Category.create!(name: "Mariages")
    first = HomeFeature.create!(featurable: @category)
    second = HomeFeature.create!(featurable: other_category)

    assert_equal 0, first.position
    assert_equal 1, second.position
  end

  test "is not valid when the same featurable is added twice" do
    HomeFeature.create!(featurable: @category)
    duplicate = HomeFeature.new(featurable: @category)

    assert_not duplicate.valid?
  end

  test "is destroyed when its category is destroyed" do
    home_feature = HomeFeature.create!(featurable: @category)
    @category.destroy

    assert_not HomeFeature.exists?(home_feature.id)
  end

  test "is destroyed when its photo is destroyed" do
    subcategory = Subcategory.create!(name: "Boiler Room", category: @category)
    photo = Photo.create!(subcategory: subcategory)
    home_feature = HomeFeature.create!(featurable: photo)

    photo.destroy

    assert_not HomeFeature.exists?(home_feature.id)
  end

  test "label returns the category name" do
    home_feature = HomeFeature.create!(featurable: @category)
    assert_equal @category.name, home_feature.label
  end

  test "label returns the photo title" do
    subcategory = Subcategory.create!(name: "Boiler Room", category: @category)
    photo = Photo.create!(subcategory: subcategory, title: "Set de clôture")
    home_feature = HomeFeature.create!(featurable: photo)

    assert_equal "Set de clôture", home_feature.label
  end

  test "type_label returns a readable french label" do
    home_feature = HomeFeature.create!(featurable: @category)
    assert_equal "Catégorie", home_feature.type_label
  end

  test "colspan defaults to 1" do
    home_feature = HomeFeature.create!(featurable: @category)
    assert_equal 1, home_feature.colspan
  end

  test "colspan must be between 1 and 3" do
    home_feature = HomeFeature.new(featurable: @category, colspan: 4)
    assert_not home_feature.valid?
  end
end
