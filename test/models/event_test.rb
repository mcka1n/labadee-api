require 'test_helper'

class EventTest < ActiveSupport::TestCase
  test 'relationships round trip through BSON foreign keys' do
    user = create_user
    event = create_event(user)
    attendee = Attendee.create!(user_id: user.id.to_s, event_id: event.id.to_s)
    assert_equal user, event.reload.user
    assert_equal event, attendee.reload.event
    assert_equal user, attendee.user
    assert_kind_of BSON::ObjectId, attendee.event_id
    assert_equal event.id, attendee.event_id
    assert_equal user.id, event.user_id
    assert_equal user.id, Event.collection.find(_id: event.id).first['user_id']
    assert_equal event.id, Attendee.collection.find(_id: attendee.id).first['event_id']
    assert_includes user.events.to_a, event
    assert_includes event.attendees.to_a, attendee
  end

  test 'name and user are required and event names are unique' do
    user = create_user
    create_event(user)
    refute Event.new(user_id: user.id.to_s).valid?
    refute Event.new(name: 'Without an owner').valid?
    refute Event.new(name: 'Beach gathering', user_id: user.id.to_s).valid?
  end

  test 'duplicate attendance is rejected and timestamps are stored' do
    user = create_user
    event = create_event(user)
    first = Attendee.create!(user_id: user.id.to_s, event_id: event.id.to_s)
    refute Attendee.new(user_id: user.id.to_s, event_id: event.id.to_s).valid?
    assert first.created_at
    assert first.updated_at
  end

  test 'deleting an event deletes its attendees' do
    user = create_user
    event = create_event(user)
    Attendee.create!(user_id: user.id.to_s, event_id: event.id.to_s)
    event.destroy
    assert_equal 0, Attendee.count
  end

  test 'address changes geocode and unrelated changes preserve coordinates' do
    user = create_user
    event = create_event(user, address: 'Harbor Street')
    assert_equal [13.405, 52.52], event.reload.coordinates
    event.update!(description: 'Changed description')
    assert_equal [13.405, 52.52], event.reload.coordinates
    assert_equal 'Harbor Street', event.full_address
    event.zip = '10115'
    assert event.full_address_changed?
    event.save!
    assert_equal [13.405, 52.52], event.reload.coordinates
  end

  test 'an empty geocoder result does not prevent saving' do
    Geocoder::Lookup::Test.add_stub('Unknown address', [])
    event = create_event(create_user, address: 'Unknown address')
    assert_nil event.reload.coordinates
  end

  test 'search matches event names without case sensitivity' do
    event = create_event(create_user)
    assert_equal [event], Event.search('BEACH').to_a
    assert_equal [event], Event.search('').to_a
    assert_empty Event.search('missing').to_a
  end
end
