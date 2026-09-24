class ApplicationController < ActionController::Base
  # Recette client (Axe 7) : toute la préprod est protégée par un mot de passe
  # partagé, tant que la mise en ligne officielle n'a pas eu lieu.
  http_basic_authenticate_with name: ENV.fetch("STAGING_HTTP_AUTH_USER", "balikvision"),
                                password: ENV.fetch("STAGING_HTTP_AUTH_PASSWORD", ""),
                                if: -> { Rails.env.staging? }

  before_action :set_active_storage_current_url_options
  after_action :set_staging_noindex_header, if: -> { Rails.env.staging? }

  private

  # Nécessaire pour le service Disk (env. test) ; sans effet sur Cloudinary
  def set_active_storage_current_url_options
    ActiveStorage::Current.url_options = { host: request.host, protocol: request.protocol, port: request.optional_port }
  end

  # Recette client : la préprod ne doit jamais être indexée par les moteurs de recherche
  def set_staging_noindex_header
    response.headers["X-Robots-Tag"] = "noindex, nofollow"
  end
end
