require 'test_helper'
require 'minitest/mock'

class SetupTest < ActiveSupport::TestCase
  test 'seeds are repeatable and preserve credentials without logging them' do
    with_seed_environment('SEED_PASSWORD' => 'private-seed-password-42') do
      output, = capture_io { load Rails.root.join('db/seeds.rb') }
      user = User.first
      client = Client.first
      password_hash = user.encrypted_password
      key = client.key
      capture_io { load Rails.root.join('db/seeds.rb') }
      assert_equal 1, User.count
      assert_equal 1, Client.count
      assert_equal password_hash, user.reload.encrypted_password
      assert_equal key, client.reload.key
      assert user.valid_password?('private-seed-password-42')
      refute_includes output, 'private-seed-password-42'
      refute_includes output, key
    end
  end

  test 'missing seed passwords fail before creating any records' do
    with_seed_environment('SEED_PASSWORD' => '') do
      assert_raises(RuntimeError) { load Rails.root.join('db/seeds.rb') }
      assert_equal 0, User.count
      assert_equal 0, Client.count
    end
  end

  test 'development seeds cannot run in production' do
    Rails.stub(:env, ActiveSupport::StringInquirer.new('production')) do
      assert_raises(RuntimeError) { load Rails.root.join('db/seeds.rb') }
    end
    assert_equal 0, User.count
    assert_equal 0, Client.count
  end

  private

  def with_seed_environment(overrides)
    values = { 'SEED_EMAIL' => 'SEED@example.test', 'SEED_CLIENT_NAME' => 'Seed client' }.merge(overrides)
    previous = values.keys.to_h { |key| [key, ENV[key]] }
    values.each { |key, value| ENV[key] = value }
    yield
  ensure
    previous.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  end
end
