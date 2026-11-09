require 'test_helper'

class CorsTest < ApiTest
  test 'browser preflight permits JSON reads and creation' do
    %w[GET POST].each do |method|
      result = Rack::MockRequest.new(Rails.application).request('OPTIONS', '/v1/events',
        'HTTP_ORIGIN' => 'http://localhost:8080',
        'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => method,
        'HTTP_ACCESS_CONTROL_REQUEST_HEADERS' => 'content-type')
      assert_equal 200, result.status
      assert_equal '*', result.headers['Access-Control-Allow-Origin']
      assert_includes result.headers['Access-Control-Allow-Methods'], method
    end
  end
end
