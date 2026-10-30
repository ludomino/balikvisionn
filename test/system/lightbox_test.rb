require "application_system_test_case"

class LightboxTest < ApplicationSystemTestCase
  setup do
    @category = Category.create!(name: "Voyages")
    @subcategory = Subcategory.create!(name: "Portugal", description: "Été 2024", category: @category, status: "published")
    3.times do |i|
      photo = @subcategory.photos.build(alt_text: "Photo numéro #{i + 1}", colspan: 1, position: i)
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

    find(".lightbox-next").click
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

  test "affiche le titre et la description de la photo dans la lightbox" do
    @subcategory.photos.first.update!(title: "Lisbonne", description: "Vue sur le Tage au coucher du soleil")

    visit category_path(@category)
    first(".mosaic-photo").click

    within "[data-lightbox-target='overlay']" do
      assert_selector ".lightbox-caption-title", text: /lisbonne/i
      assert_selector ".lightbox-caption-description", text: "Vue sur le Tage au coucher du soleil"
    end
  end

  test "masque la légende quand la photo n'a ni titre ni description" do
    visit category_path(@category)
    first(".mosaic-photo").click

    within "[data-lightbox-target='overlay']" do
      assert_selector ".lightbox-caption", visible: false
    end
  end

  test "le bouton fermer n'affiche que le symbole × (pas de texte)" do
    visit category_path(@category)
    first(".mosaic-photo").click

    within "[data-lightbox-target='overlay']" do
      assert_selector ".lightbox-close", text: "✕", exact_text: true
      assert_selector ".lightbox-close[aria-label='Fermer']"
    end
  end

  test "affiche un compteur de position centré en bas de page" do
    visit category_path(@category)
    first(".mosaic-photo").click

    within "[data-lightbox-target='overlay']" do
      assert_selector ".lightbox-counter", text: "1 / 3"
      find(".lightbox-next").click
      assert_selector ".lightbox-counter", text: "2 / 3"
    end
  end

  test "une photo au format paysage ne subit pas le recadrage portrait 4:5" do
    @subcategory.photos.second.update_columns(width: 2000, height: 1000)

    visit category_path(@category)
    all(".mosaic-photo")[1].click

    within "[data-lightbox-target='overlay']" do
      assert_selector ".lightbox-photo.is-landscape"
    end
  end
end
