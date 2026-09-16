class AboutController < ApplicationController
  def show
    @about_page = AboutPage.instance
    @contact = Contact.new
  end
end
