class ContactMailer < ApplicationMailer
  CONTACT_ADDRESS = "balik.vision.contact@gmail.com"

  def notification(contact)
    @contact = contact
    mail subject: "Nouveau message de #{contact.name} via le site", to: CONTACT_ADDRESS, reply_to: contact.email
  end
end
