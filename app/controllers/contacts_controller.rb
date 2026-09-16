class ContactsController < ApplicationController
  def create
    @contact = Contact.new(contact_params)

    if @contact.spam?
      # Réponse identique à un succès : on ne révèle jamais au bot que le honeypot a été détecté
      redirect_to about_path, notice: "Message envoyé, merci !"
      return
    end

    if @contact.valid?
      ContactMailer.notification(@contact).deliver_now
      redirect_to about_path, notice: "Message envoyé, merci !"
    else
      @about_page = AboutPage.instance
      render "about/show", status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :message, :nickname)
  end
end
