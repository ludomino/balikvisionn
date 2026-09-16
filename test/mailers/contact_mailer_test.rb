require "test_helper"

class ContactMailerTest < ActionMailer::TestCase
  test "notification sends an email to the site's contact address" do
    contact = Contact.new(
      name: "Jean Dupont",
      email: "jean@example.com",
      message: "Bonjour, je suis intéressé par une séance photo."
    )

    email = ContactMailer.notification(contact).deliver_now

    assert_emails 1
    assert_equal [ContactMailer::CONTACT_ADDRESS], email.to
    assert_equal [contact.email], email.reply_to
    assert_match contact.name, email.subject
    assert_match contact.message, email.text_part.decoded
  end
end
