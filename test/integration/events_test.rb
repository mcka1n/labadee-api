require 'test_helper'

class EventsTest < ApiTest
  test 'listing and showing events preserve the JSON fields' do
    event = create_event(@user, start_date: DateTime.iso8601('2026-11-09T09:30:00Z'))
    attendee = Attendee.create!(event_id: event.id.to_s, user_id: @user.id.to_s)
    get api_path('/v1/events')
    assert_json_response 200
    assert_equal 1, json.length
    get api_path('/v1/events/' + event.id.to_s)
    assert_json_response 200
    assert_equal %w[id user_id name description address zip country start_date end_date category coordinates rank hide attendees created_at updated_at].sort, json.keys.sort
    assert_equal event.id.to_s, json['id']
    assert_equal @user.id.to_s, json['user_id']
    assert_equal 'Beach gathering', json['name']
    assert_equal false, json['hide']
    assert_equal 0.0, json['rank']
    assert_nil json['end_date']
    assert_equal DateTime.iso8601('2026-11-09T09:30:00Z'), DateTime.iso8601(json['start_date'])
    assert_equal attendee.id.to_s, json['attendees'].first['id']
    assert_equal event.id.to_s, json['attendees'].first['event_id']
    assert json['created_at'].is_a?(String)
    assert json['updated_at'].is_a?(String)
  end

  test 'a missing event returns an empty object and 404' do
    get api_path('/v1/events/' + BSON::ObjectId.new.to_s)
    assert_json_response 404
    assert_equal({}, json)
  end

  test 'creation uses the authenticated user' do
    json_request :post, '/v1/events', event: { name: 'Created by API' }
    assert_json_response 200
    assert_equal 'Created by API', json['name']
    assert_equal @user.id.to_s, json['user_id']
    assert_equal 1, @user.events.count
  end

  test 'invalid event creation returns field errors' do
    json_request :post, '/v1/events', event: { description: 'Missing name' }
    assert_json_response 422
    assert json.key?('name')
    assert_equal 0, Event.count
  end

  test 'event updates persist and return the event' do
    event = create_event(@user)
    json_request :put, '/v1/events/' + event.id.to_s, event: { description: 'New description' }
    assert_json_response 200
    assert_equal 'New description', json['description']
    assert_equal 'New description', event.reload.description
  end

  test 'event deletion removes dependent attendance' do
    event = create_event(@user)
    Attendee.create!(event_id: event.id.to_s, user_id: @user.id.to_s)
    delete api_path('/v1/events/' + event.id.to_s)
    assert_response 204
    assert_nil Event.where(id: event.id).first
    assert_equal 0, Attendee.count
  end
end
