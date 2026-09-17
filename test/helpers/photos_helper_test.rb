require "test_helper"

class PhotosHelperTest < ActionView::TestCase
  test "retourne un format carré pour colspan 1" do
    assert_equal [500, 500], photo_mosaic_dimensions(1)
  end

  test "retourne un format large pour colspan 2" do
    assert_equal [1000, 500], photo_mosaic_dimensions(2)
  end

  test "retourne un format très large pour colspan 3" do
    assert_equal [1500, 500], photo_mosaic_dimensions(3)
  end

  test "retombe sur le format carré si colspan est inattendu" do
    assert_equal [500, 500], photo_mosaic_dimensions(nil)
  end
end
