require "test_helper"

class AboutPageTest < ActiveSupport::TestCase
  test "instance creates a singleton row when none exists" do
    assert_difference "AboutPage.count", 1 do
      AboutPage.instance
    end
  end

  test "instance returns the same row on subsequent calls" do
    first_call = AboutPage.instance
    second_call = AboutPage.instance

    assert_equal first_call.id, second_call.id
  end
end
