require "application_system_test_case"

class Admin::HomeFeatureKeyboardReorderingTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @category = Category.create!(name: "Concerts")
    @subcategory = Subcategory.create!(name: "Jimmy Set", description: "Concert du 12 mars", category: @category)
    @first = @category.create_home_feature!
    @second = @subcategory.create_home_feature!
  end

  test "pressing the down arrow on a handle swaps it with the next item" do
    system_sign_in_as @user

    visit admin_home_features_path

    handle = find("div[data-id='#{@first.id}'] .admin-mosaic-handle")
    handle.send_keys(:arrow_down)

    wait_for_position(@second, 0)
    wait_for_position(@first, 1)
  end

  test "pressing the up arrow on the first handle does nothing" do
    system_sign_in_as @user

    visit admin_home_features_path

    handle = find("div[data-id='#{@first.id}'] .admin-mosaic-handle")
    handle.send_keys(:arrow_up)

    assert_equal 0, @first.reload.position
    assert_equal 1, @second.reload.position
  end

  test "moving announces the new position for screen readers" do
    system_sign_in_as @user

    visit admin_home_features_path

    handle = find("div[data-id='#{@first.id}'] .admin-mosaic-handle")
    handle.send_keys(:arrow_down)

    assert_selector "[role='status']", text: /position 2 sur 2/i
  end

  private

  # Le contrôleur persiste via fetch() en JS, de façon asynchrone : on
  # attend le résultat en base plutôt que de supposer qu'il est déjà là
  # (même pattern que photo_reordering_test.rb).
  def wait_for_position(home_feature, expected_position, timeout: 5)
    Timeout.timeout(timeout) do
      loop do
        break if home_feature.reload.position == expected_position
        sleep 0.1
      end
    end
  rescue Timeout::Error
    flunk "Position de ##{home_feature.id} non mise à jour (attendu #{expected_position}, obtenu #{home_feature.reload.position})"
  end
end
