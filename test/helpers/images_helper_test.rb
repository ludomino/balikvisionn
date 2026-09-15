require "test_helper"

class ImagesHelperTest < ActionView::TestCase
  setup { ActiveStorage::Current.url_options = { host: "http://test.host" } }
  test "returns nil when nothing is attached" do
    category = Category.new
    assert_nil cloudinary_image_tag(category.cover, alt: "test")
  end

  test "renders an image tag with lazy loading and alt text" do
    category = Category.create!(name: "Concerts")
    category.cover.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "test_photo.png",
      content_type: "image/png"
    )

    html = cloudinary_image_tag(category.cover, alt: "Couverture Concerts", width: 400, height: 300, crop: :fill)

    assert_match %r{<img}, html
    assert_match %r{alt="Couverture Concerts"}, html
    assert_match %r{loading="lazy"}, html
  end
end
