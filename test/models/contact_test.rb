require "test_helper"

class ContactTest < ActiveSupport::TestCase
  test "valid with name, email and message" do
    contact = Contact.new(name: "Jean", email: "jean@example.com", message: "Bonjour")
    assert contact.valid?
  end

  test "invalid without name" do
    contact = Contact.new(email: "jean@example.com", message: "Bonjour")
    assert_not contact.valid?
  end

  test "invalid without email" do
    contact = Contact.new(name: "Jean", message: "Bonjour")
    assert_not contact.valid?
  end

  test "invalid with a malformed email" do
    contact = Contact.new(name: "Jean", email: "pas-un-email", message: "Bonjour")
    assert_not contact.valid?
  end

  test "invalid without message" do
    contact = Contact.new(name: "Jean", email: "jean@example.com")
    assert_not contact.valid?
  end

  test "spam? is true when the honeypot field is filled" do
    # Un humain ne voit jamais ce champ (caché en CSS) ; un bot qui le remplit se trahit
    contact = Contact.new(name: "Bot", email: "bot@example.com", message: "spam", nickname: "http://spam.com")
    assert contact.spam?
  end

  test "spam? is false when the honeypot field is blank" do
    contact = Contact.new(name: "Jean", email: "jean@example.com", message: "Bonjour")
    assert_not contact.spam?
  end
end
