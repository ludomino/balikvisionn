require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "assigns position automatically on create" do
    first = Category.create!(name: "Concerts")
    second = Category.create!(name: "Mariages")

    assert_equal 0, first.position
    assert_equal 1, second.position
  end

  test "Category.order(:position) respects a manually changed position" do
    first = Category.create!(name: "Concerts")
    second = Category.create!(name: "Mariages")
    second.update_column(:position, -1)

    assert_equal [second, first], Category.order(:position).where(id: [first.id, second.id]).to_a
  end

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

  test "enforce_draft_unless_content! drafts a published category with no cover and no subcategory" do
    category = Category.create!(name: "Concerts")

    category.enforce_draft_unless_content!

    assert category.draft?
  end

  test "enforce_draft_unless_content! drafts a published category with a cover but no subcategory" do
    category = Category.create!(name: "Concerts")
    category.cover.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "test_photo.png",
      content_type: "image/png"
    )

    category.enforce_draft_unless_content!

    assert category.draft?
  end

  test "enforce_draft_unless_content! drafts a published category with a subcategory but no cover" do
    category = Category.create!(name: "Concerts")
    category.subcategories.create!(name: "Boiler Room")

    category.enforce_draft_unless_content!

    assert category.draft?
  end

  test "enforce_draft_unless_content! leaves a published category alone once it has a cover and a subcategory" do
    category = Category.create!(name: "Concerts")
    category.cover.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "test_photo.png",
      content_type: "image/png"
    )
    category.subcategories.create!(name: "Boiler Room")

    category.enforce_draft_unless_content!

    assert category.published?
  end

  test "enforce_draft_unless_content! never republishes a draft category" do
    category = Category.create!(name: "Concerts", status: "draft")
    category.cover.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "test_photo.png",
      content_type: "image/png"
    )
    category.subcategories.create!(name: "Boiler Room")

    category.enforce_draft_unless_content!

    assert category.draft?
  end

  test "enforce_draft_unless_content! forcing draft via a missing cover still cascades to existing subcategories" do
    category = Category.create!(name: "Concerts") # publiée par défaut (enum), sans couverture
    subcategory = category.subcategories.create!(name: "Boiler Room", status: "published")

    category.enforce_draft_unless_content!

    assert category.reload.draft?
    assert subcategory.reload.draft?
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
