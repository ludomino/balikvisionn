ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # fixture_file_upload dispo dans tous les tests de modèle (pas que les contrôleurs)
  include ActionDispatch::TestProcess::FixtureFile

  # perform_enqueued_jobs : nécessaire pour tester la purge Active Storage (async par défaut)
  include ActiveJob::TestHelper
end
