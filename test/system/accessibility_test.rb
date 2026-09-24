require "application_system_test_case"

class AccessibilityTest < ApplicationSystemTestCase
  AXE_SOURCE = File.read(Rails.root.join("test/support/axe.min.js"))

  setup do
    @user = users(:one)
    @category = Category.create!(name: "Concerts")
    @subcategory = Subcategory.create!(name: "Jimmy Set", description: "Concert du 12 mars", category: @category)
    photo = @subcategory.photos.build(alt_text: "Photo test", colspan: 1)
    photo.image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "test_photo.png",
      content_type: "image/png"
    )
    photo.save!
  end

  test "aucune violation axe-core critique/sérieuse sur les pages publiques" do
    { "Accueil" => root_path, "Page catégorie" => category_path(@category), "À propos" => about_path }.each do |name, path|
      visit path
      assert_no_axe_violations(name)
    end
  end

  test "aucune violation axe-core critique/sérieuse sur les pages admin" do
    system_sign_in_as @user

    {
      "Dashboard" => admin_root_path,
      "Fiche catégorie" => admin_category_path(@category),
      "Formulaire sous-catégorie" => edit_admin_category_subcategory_path(@category, @subcategory),
      "Formulaire À propos" => edit_admin_about_page_path,
    }.each do |name, path|
      visit path
      assert_no_axe_violations(name)
    end
  end

  private

  def assert_no_axe_violations(page_name)
    page.execute_script(AXE_SOURCE)
    violations = page.evaluate_async_script(<<~JS)
      var callback = arguments[arguments.length - 1];
      axe.run(document, { runOnly: ["wcag2a", "wcag2aa"] }).then(function(results) {
        callback(results.violations.filter(function(v) { return v.impact === "critical" || v.impact === "serious"; }));
      });
    JS

    details = violations.map { |v| "- #{v['id']} (#{v['impact']}): #{v['help']} — #{v['nodes'].size} élément(s)" }.join("\n")
    assert_empty violations, "Violations a11y sur \"#{page_name}\" :\n#{details}"
  end
end
