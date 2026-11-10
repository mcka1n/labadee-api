require 'test_helper'

class ClientTest < ActiveSupport::TestCase
  test 'clients get a persistent key and a unique required name' do
    client = Client.create!(name: 'Consumer')
    assert client.key.present?
    assert_equal client.key, client.reload.key
    refute Client.new(name: 'Consumer').valid?
    refute Client.new.valid?
  end
end
