require "test_helper"

class AboutControllerTest < ActionDispatch::IntegrationTest
  test "show displays the biography" do
    AboutPage.instance.update!(biography: "Photographe passionné depuis 10 ans.")

    get about_path

    assert_response :success
    assert_select "body", text: /Photographe passionné depuis 10 ans/
  end

  test "show works even when no biography has been entered yet" do
    get about_path

    assert_response :success
  end
end
