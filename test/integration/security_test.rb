require 'test_helper'

class SecurityTest < ApiTest
  test 'only the event owner can update or delete an event' do
    event = create_event(@user)
    other = create_user('other@example.test')
    path = '/v1/events/' + event.id.to_s
    json_request :put, path, { event: { name: 'Stolen event' } }, token: other.token
    assert_json_response 403
    assert_equal 'Beach gathering', event.reload.name
    delete api_path(path, token: other.token)
    assert_json_response 403
    assert Event.where(id: event.id).exists?
  end

  test 'clients cannot replace ownership or internal timestamps' do
    event = create_event(@user)
    other = create_user('other@example.test')
    created_at = event.reload.created_at
    json_request :put, '/v1/events/' + event.id.to_s,
      event: { description: 'Allowed change', user_id: other.id.to_s, created_at: '2000-01-01', updated_at: '2000-01-01' }
    assert_json_response 200
    event.reload
    assert_equal @user.id, event.user_id
    assert_equal created_at, event.created_at
    assert_equal 'Allowed change', event.description
    assert_operator event.updated_at.year, :>, 2000
  end

  test 'invalid updates return field errors and preserve the saved event' do
    event = create_event(@user)
    json_request :patch, '/v1/events/' + event.id.to_s, event: { name: '' }
    assert_json_response 422
    assert json.key?('name')
    assert_equal 'Beach gathering', event.reload.name
  end

  test 'missing and malformed event ids return consistent JSON errors' do
    [BSON::ObjectId.new.to_s, 'not-an-id'].each do |id|
      path = '/v1/events/' + id
      get api_path(path)
      assert_json_response 404
      assert_equal({}, json)
      json_request :put, path, event: { name: 'Missing' }
      assert_json_response 404
      assert_equal({}, json)
      delete api_path(path)
      assert_json_response 404
      json_request :post, path + '/attendees', {}
      assert_json_response 404
      assert_equal({}, json)
    end
  end

  test 'an attendee cannot be read through another event' do
    event = create_event(@user)
    other_event = create_event(@user, name: 'Other event')
    attendee = Attendee.create!(event: event, user: @user)
    get api_path('/v1/events/' + other_event.id.to_s + '/attendees/' + attendee.id.to_s)
    assert_json_response 404
    assert_equal({}, json)
    get api_path('/v1/events/' + event.id.to_s + '/attendees/not-an-id')
    assert_json_response 404
  end

  test 'structured credential values cannot become MongoDB selectors' do
    get '/v1/events', params: { key: { '$ne' => 'missing' }, token: @user.token }
    assert_json_response 401
    assert_equal({ 'message' => 'Invalid Client Key' }, json)
    get '/v1/events', params: { key: @client.key, token: { '$ne' => 'missing' } }
    assert_json_response 401
    assert_equal({ 'message' => 'Invalid token' }, json)
    get '/v1/events', params: { key: @client.key, token: [@user.token] }
    assert_json_response 401
  end

  test 'malformed login objects fail without querying using structured values' do
    json_request :post, '/v1/users/sign_in', { user: 'invalid' }, token: nil
    assert_json_response 422
    json_request :post, '/v1/users/sign_in', { user: { email: { '$ne' => '' }, password: 'invalid' } }, token: nil
    assert_json_response 401
  end
end
