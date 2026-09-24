require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Reprend la configuration de production.rb : la préprod doit se comporter
  # comme la prod (mêmes optimisations, pas de traces d'erreur exposées au client).
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }
  config.assets.compile = false

  config.active_storage.service = :cloudinary

  # Différence avec la prod : logs verbeux pour faciliter le débogage pendant la recette client.
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "debug")
  config.log_tags = [ :request_id ]
  config.silence_healthcheck_path = "/up"

  config.action_mailer.perform_caching = false

  # Différence avec la prod : host configurable par variable d'environnement,
  # le sous-domaine de préprod n'étant pas encore connu au moment d'écrire ce fichier.
  config.action_mailer.default_url_options = { host: ENV.fetch("STAGING_HOST", "example.com") }

  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false
  config.log_formatter = ::Logger::Formatter.new

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [ :id ]
end
