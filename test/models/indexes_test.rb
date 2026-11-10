require 'test_helper'

class IndexesTest < ActiveSupport::TestCase
  test 'MongoDB rejects duplicate attendance even when validations are bypassed' do
    user = create_user
    event = create_event(user)
    attendee = Attendee.create!(event: event, user: user)
    duplicate = Attendee.collection.find(_id: attendee.id).first.merge('_id' => BSON::ObjectId.new)
    error = assert_raises(Mongo::Error::OperationFailure) { Attendee.collection.insert_one(duplicate) }
    assert_equal 11000, error.code
    assert_equal 1, Attendee.count
  end
end
