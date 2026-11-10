require 'test_helper'
require 'stringio'

class DatabaseLoggingTest < ApiTest
  test 'real authentication queries do not log credential values' do
    previous_driver = Mongo::Logger.logger
    previous_odm = Mongoid.logger
    output = StringIO.new
    capture_logger = Logger.new(output)
    capture_logger.level = previous_driver.level
    Mongo::Logger.logger = capture_logger
    Mongoid.logger = capture_logger

    get api_path('/v1/events')
    assert_response 200
    refute_includes output.string, @client.key
    refute_includes output.string, @user.token
  ensure
    Mongo::Logger.logger = previous_driver
    Mongoid.logger = previous_odm
  end
end
