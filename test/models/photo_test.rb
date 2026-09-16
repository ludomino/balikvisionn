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

    test "acceptable_upload? rejects a non-image file" do
    file = fixture_file_upload("fake.txt", "text/plain")
    assert_not Photo.acceptable_upload?(file)
  end

  test "acceptable_upload? accepts a real image within size limit" do
    file = fixture_file_upload("test_photo.png", "image/png")
    assert Photo.acceptable_upload?(file)
  end

  test "acceptable_upload? rejects a file larger than the max size" do
    # fichier réel (type valide) dont on force la taille déclarée au-delà du seuil, pour isoler le check de taille
    oversized = fixture_file_upload("test_photo.png", "image/png")
    oversized.define_singleton_method(:size) { 21.megabytes }

    assert_not Photo.acceptable_upload?(oversized)
  end

  test "acceptable_upload? rejects a file larger than Cloudinary's own 10MB limit" do
    # Cloudinary refuse tout fichier > 10 Mo (confirmé par l'erreur réelle) ; notre check doit refléter cette vraie limite
    oversized = fixture_file_upload("test_photo.png", "image/png")
    oversized.define_singleton_method(:size) { 15.megabytes }

    assert_not Photo.acceptable_upload?(oversized)
  end

  test "move_higher swaps position with the previous photo" do
    photo_a = Photo.create!(subcategory: @subcategory, colspan: 1, position: 0)
    photo_b = Photo.create!(subcategory: @subcategory, colspan: 1, position: 1)

    photo_b.move_higher

    assert_equal 0, photo_b.reload.position
    assert_equal 1, photo_a.reload.position
  end

  test "move_higher does nothing when already first" do
    photo_a = Photo.create!(subcategory: @subcategory, colspan: 1, position: 0)

    photo_a.move_higher

    assert_equal 0, photo_a.reload.position
  end

  test "move_lower swaps position with the next photo" do
    photo_a = Photo.create!(subcategory: @subcategory, colspan: 1, position: 0)
    photo_b = Photo.create!(subcategory: @subcategory, colspan: 1, position: 1)

    photo_a.move_lower

    assert_equal 1, photo_a.reload.position
    assert_equal 0, photo_b.reload.position
  end

  test "move_lower does nothing when already last" do
    photo_b = Photo.create!(subcategory: @subcategory, colspan: 1, position: 1)

    photo_b.move_lower

    assert_equal 1, photo_b.reload.position
  end

  test "destroying a photo purges its attached blob" do
    photo = Photo.create!(subcategory: @subcategory, colspan: 1, position: 0)
    photo.image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "test_photo.png",
      content_type: "image/png"
    )
    blob = photo.image.blob

    perform_enqueued_jobs do
      photo.destroy
    end

    assert_not ActiveStorage::Blob.exists?(blob.id)
  end
end
