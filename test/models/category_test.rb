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

  test "nouvelle catégorie est publiée par défaut" do
    category = Category.create!(name: "Concerts")
    assert category.published?
  end

  test "peut passer en brouillon" do
    category = Category.create!(name: "Concerts")
    category.draft!
    assert category.draft?
  end

  test "passer une catégorie en brouillon met aussi ses sous-catégories en brouillon" do
    category = Category.create!(name: "Concerts")
    boiler_room = category.subcategories.create!(name: "Boiler Room", status: "published")
    jimmy_set = category.subcategories.create!(name: "Jimmy Set", status: "published")

    category.update!(status: "draft")

    assert boiler_room.reload.draft?
    assert jimmy_set.reload.draft?
  end

  test "republier une catégorie ne republie pas automatiquement ses sous-catégories" do
    category = Category.create!(name: "Concerts", status: "draft")
    subcategory = category.subcategories.create!(name: "Boiler Room", status: "draft")

    category.update!(status: "published")

    assert subcategory.reload.draft?
  end
end
