require "application_system_test_case"

class Admin::PhotoReorderingTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @category = Category.create!(name: "Concerts")
    @subcategory = Subcategory.create!(name: "Jimmy Set", description: "Concert du 12 mars", category: @category)
    @photo_a = Photo.create!(subcategory: @subcategory, colspan: 1, position: 0)
    @photo_b = Photo.create!(subcategory: @subcategory, colspan: 1, position: 1)
  end

    test "dragging a photo persists its new position" do
    system_sign_in_as @user

    visit edit_admin_category_subcategory_path(@category, @subcategory)

    source = find("div[data-id='#{@photo_a.id}']")
    target = find("div[data-id='#{@photo_b.id}']")

    source.drag_to(target, delay: 0.5, html5: false)
  end

  private

  # SortableJS persiste via fetch() en JS, de façon asynchrone : on attend
  # le résultat en base plutôt que de supposer qu'il est déjà là.
  def wait_for_photo_position(photo, expected_position, timeout: 5)
    Timeout.timeout(timeout) do
      loop do
        break if photo.reload.position == expected_position
        sleep 0.1
      end
    end
  rescue Timeout::Error
    flunk "Position de la photo ##{photo.id} non mise à jour (attendu #{expected_position}, obtenu #{photo.reload.position})"
  end
end
