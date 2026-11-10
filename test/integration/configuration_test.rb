require 'test_helper'

class ConfigurationTest < ActiveSupport::TestCase
  test 'SQL and unused framework engines remain disabled' do
    railties = Rails.application.railties.map { |railtie| railtie.class.name }
    %w[ActiveRecord::Railtie ActiveStorage::Engine ActionText::Engine ActionMailbox::Engine ActionCable::Engine].each do |name|
      refute_includes railties, name
    end
  end
end
