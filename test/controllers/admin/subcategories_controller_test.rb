require "test_helper"

class Admin::SubcategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @category = Category.create!(name: "Concerts")
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
end
