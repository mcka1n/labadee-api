ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'geocoder/lookups/test'

Geocoder.configure(lookup: :test)

class ActiveSupport::TestCase
  setup do
    database = Mongoid.default_client.database.name
    raise "Refusing to clean non-test database #{database}" unless Rails.env.test? && database.end_with?('_test')

    [Attendee, Event, User, Client].each(&:delete_all)
    ActionMailer::Base.deliveries.clear
    Geocoder::Lookup::Test.reset
    Geocoder::Lookup::Test.set_default_stub([{
      'coordinates' => [52.52, 13.405],
      'address' => 'Harbor Street',
      'country' => 'Germany',
      'country_code' => 'DE'
    }])
  end

  def create_user(email = 'person@example.test')
    user = User.create!(email: email, password: 'test-password-42')
    user.assign_fresh_token!
    user
  end

  def create_event(user, attributes = {})
    Event.create!({ name: 'Beach gathering', user_id: user.id.to_s }.merge(attributes))
  end
end

class ApiTest < ActionDispatch::IntegrationTest
  setup do
    @client = Client.create!(name: 'Test client')
    @user = create_user
  end

  def api_path(path, credentials = {})
    query = { key: @client.key, token: @user.token }.merge(credentials)
    path + '?' + Rack::Utils.build_query(query)
  end

  def json_request(method, path, payload, credentials = {})
    public_send(method, api_path(path, credentials), params: payload.to_json,
      headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' })
  end

  def json
    JSON.parse(response.body)
  end

  def assert_json_response(status)
    assert_response status
    assert_equal 'application/json', response.media_type
  end
end
