require_relative 'boot'
require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'rails/test_unit/railtie'

Bundler.require(*Rails.groups)

module LabadeeApi
  class Application < Rails::Application
    config.load_defaults 8.1
    # Existing Devise sign_in calls require the full session middleware stack.
    # Controllers still inherit ActionController::API; SQL frameworks stay off.
    config.api_only = false
    config.active_job.queue_adapter = :async
    config.generators { |generator| generator.orm :mongoid }

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :options]
      end
    end
  end
end
