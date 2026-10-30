require "application_system_test_case"

class Admin::MosaicCardAltPanelTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @category = Category.create!(name: "Concerts")
    @subcategory = Subcategory.create!(name: "Jimmy Set", description: "Concert du 12 mars", category: @category)
    @photo = Photo.create!(subcategory: @subcategory, colspan: 1, position: 0)
  end

  test "le bouton crayon ouvre le panneau titre/description, le bouton fermer le referme" do
    system_sign_in_as @user
    visit edit_admin_category_subcategory_path(@category, @subcategory)

    card = find("div[data-id='#{@photo.id}']")

    within card do
      assert_no_selector ".admin-mosaic-overlay-bottom"

      find(".admin-mosaic-icon-btn[title='Titre, description & texte alternatif']").click
      assert_selector ".admin-mosaic-overlay-bottom"

      find(".admin-mosaic-alt-close").click
      assert_no_selector ".admin-mosaic-overlay-bottom"
    end
  end
end
