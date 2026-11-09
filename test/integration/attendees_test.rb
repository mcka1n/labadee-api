require 'test_helper'

class AttendeesTest < ApiTest
  setup do
    @event = create_event(@user)
    @path = '/v1/events/' + @event.id.to_s + '/attendees'
  end

  test 'creation and nested reads preserve attendance JSON' do
    json_request :post, @path, {}
    assert_json_response 200
    assert_equal %w[id user_id event_id status created_at updated_at].sort, json.keys.sort
    assert_equal @event.id.to_s, json['event_id']
    assert_equal @user.id.to_s, json['user_id']
    assert_nil json['status']
    id = json['id']
    get api_path(@path)
    assert_json_response 200
    assert_equal [id], json.map { |item| item['id'] }
    get api_path(@path + '/' + id)
    assert_json_response 200
    assert_equal id, json['id']
  end

  test 'a user cannot attend the same event twice' do
    json_request :post, @path, {}
    assert_response 200
    json_request :post, @path, {}
    assert_json_response 422
    assert json.key?('event_id')
    assert_equal 1, Attendee.count
  end

  test 'listing attendees of a missing event returns an empty array' do
    get api_path('/v1/events/' + BSON::ObjectId.new.to_s + '/attendees')
    assert_json_response 404
    assert_equal [], json
  end

  test 'a missing attendee returns an empty object' do
    get api_path(@path + '/' + BSON::ObjectId.new.to_s)
    assert_json_response 404
    assert_equal({}, json)
  end
end
