require 'test_helper'

class LogFilteringTest < ActiveSupport::TestCase
  test 'API credentials and password reset tokens are filtered' do
    parameters = { password: 'password-value', key: 'client-value', token: 'token-value',
      auth_token: 'response-value', reset_password_token: 'reset-value', email: 'person@example.test' }
    request = ActionDispatch::TestRequest.create
    request.env['action_dispatch.parameter_filter'] = Rails.application.config.filter_parameters
    request.env['action_dispatch.request.request_parameters'] = parameters
    filtered = request.filtered_parameters
    %w[password key token auth_token reset_password_token].each do |name|
      assert_equal '[FILTERED]', filtered[name.to_sym] || filtered[name]
    end
    assert_equal 'person@example.test', filtered[:email] || filtered['email']
  end
end
