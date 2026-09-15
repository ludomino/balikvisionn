class ApplicationController < ActionController::Base
  before_action :set_active_storage_current_url_options

  private

  # Nécessaire pour le service Disk (env. test) ; sans effet sur Cloudinary
  def set_active_storage_current_url_options
    ActiveStorage::Current.url_options = { host: request.host, protocol: request.protocol, port: request.optional_port }
  end
end
