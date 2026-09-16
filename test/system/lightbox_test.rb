require "application_system_test_case"

class LightboxTest < ApplicationSystemTestCase
  setup do
    @category = Category.create!(name: "Voyages")
    @subcategory = Subcategory.create!(name: "Portugal", description: "Été 2024", category: @category)
    3.times do |i|
      photo = @subcategory.photos.build(alt_text: "Photo numéro #{i + 1}", colspan: 1)
      photo.image.attach(
        io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
        filename: "test_photo.png",
        content_type: "image/png"
      )
      photo.save!
    end
  end

  test "cliquer sur une miniature ouvre la lightbox sur la bonne photo" do
    visit category_path(@category)
    first(".mosaic-photo").click

    within "[data-lightbox-target='overlay']" do
      assert_selector "img[alt='Photo numéro 1']"
    end
  end

  test "les flèches et le clavier naviguent entre les photos" do
    visit category_path(@category)
    first(".mosaic-photo").click

    click_button "Photo suivante"
    assert_selector "[data-lightbox-target='overlay'] img[alt='Photo numéro 2']"

    find("[data-lightbox-target='overlay']").send_keys(:arrow_right)
    assert_selector "[data-lightbox-target='overlay'] img[alt='Photo numéro 3']"
  end

  test "Échap ferme la lightbox" do
    visit category_path(@category)
    first(".mosaic-photo").click
    assert_selector "[data-lightbox-target='overlay'].is-open"

    find("[data-lightbox-target='overlay']").send_keys(:escape)
    assert_no_selector "[data-lightbox-target='overlay'].is-open"
  end

  test "le focus est piégé dans la lightbox (Tab boucle du dernier au premier bouton)" do
    visit category_path(@category)
    first(".mosaic-photo").click

    buttons = all("[data-lightbox-target='overlay'] button")
    last_button = buttons.last

    assert_equal buttons.first.text, page.evaluate_script("document.activeElement.textContent").strip

    last_button.send_keys(:tab)
    assert_equal buttons.first.text, page.evaluate_script("document.activeElement.textContent").strip
  end
end
