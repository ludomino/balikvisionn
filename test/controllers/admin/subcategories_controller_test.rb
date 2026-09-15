require "test_helper"

class Admin::SubcategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @category = Category.create!(name: "Concerts")
    # ... reste du setup inchangé
    @subcategory = Subcategory.create!(
      name: "Jimmy Set",
      description: "Concert du 12 mars",
      category: @category
    )

    @photo = Photo.create!(subcategory: @subcategory, colspan: 1, position: 0)
    @photo.image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "test_photo.png",
      content_type: "image/png"
    )
  end

  test "update redirects to login when not authenticated" do
    patch admin_category_subcategory_path(@category, @subcategory), params: {
      subcategory: { name: "Nouveau nom" }
    }
    assert_redirected_to new_session_path
  end

  test "updating a subcategory succeeds without raising an error when authenticated" do
    sign_in_as @user

    patch admin_category_subcategory_path(@category, @subcategory), params: {
      subcategory: { name: "Nouveau nom", description: "Nouvelle description" }
    }

    assert_redirected_to admin_category_path(@category)
    @subcategory.reload
    assert_equal "Nouveau nom", @subcategory.name
  end

  # Vérifie qu'un upload réel crée un Photo avec image attachée
  test "create attaches an uploaded photo to the new subcategory" do
    sign_in_as @user

    assert_difference "Photo.count", 1 do
      post admin_category_subcategories_path(@category), params: {
        subcategory: {
          name: "Nouvelle sous-catégorie",
          description: "Une description",
          photos: [fixture_file_upload("test_photo.png", "image/png")]
        }
      }
    end

    subcategory = Subcategory.last
    assert subcategory.photos.first.image.attached?
  end

    # Un fichier invalide ne doit pas empêcher l'upload des autres
  test "create ignores an invalid file but still attaches the valid ones" do
    sign_in_as @user

    assert_difference "Photo.count", 1 do
      post admin_category_subcategories_path(@category), params: {
        subcategory: {
          name: "Sous-catégorie mixte",
          description: "Une description",
          photos: [
            fixture_file_upload("fake.txt", "text/plain"),
            fixture_file_upload("test_photo.png", "image/png")
          ]
        }
      }
    end

    assert_match "fake.txt", flash[:alert]
  end

  # Reproduit l'entrée vide observée en prod dans photos[] : ne doit pas planter
  test "create ignores a blank entry in the photos param without raising" do
    sign_in_as @user

    assert_difference "Photo.count", 1 do
      post admin_category_subcategories_path(@category), params: {
        subcategory: {
          name: "Sous-catégorie avec entrée vide",
          description: "Une description",
          photos: ["", fixture_file_upload("test_photo.png", "image/png")]
        }
      }
    end
  end

    # Édition d'alt_text depuis le formulaire d'édition de sous-catégorie
  test "update saves alt_text for an existing photo via nested attributes" do
    sign_in_as @user

    patch admin_category_subcategory_path(@category, @subcategory), params: {
      subcategory: {
        name: @subcategory.name,
        description: @subcategory.description,
        photos_attributes: { "0" => { id: @photo.id, alt_text: "Vue de la scène" } }
      }
    }

    assert_redirected_to admin_category_path(@category)
    assert_equal "Vue de la scène", @photo.reload.alt_text
  end

  test "edit form displays an alt_text field for each existing photo" do
    sign_in_as @user

    get edit_admin_category_subcategory_path(@category, @subcategory)

    assert_select "input[name='subcategory[photos_attributes][0][id]']", value: @photo.id.to_s
    assert_select "input[name='subcategory[photos_attributes][0][alt_text]']"
  end
end
