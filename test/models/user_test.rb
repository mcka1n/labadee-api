require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'password hashes survive a reload and tokens rotate' do
    user = create_user
    token = user.token
    assert user.reload.valid_password?('test-password-42')
    refute_equal 'test-password-42', user.encrypted_password
    user.assign_fresh_token!
    refute_equal token, user.reload.token
  end

  test 'email is required and unique regardless of case' do
    create_user
    refute User.new(email: 'PERSON@example.test', password: 'test-password-42').valid?
    refute User.new(password: 'test-password-42').valid?
  end

  test 'deleting a user deletes their attendance records' do
    user = create_user
    event = create_event(user)
    attendee = Attendee.create!(user_id: user.id.to_s, event_id: event.id.to_s)
    user.destroy
    assert_nil Attendee.where(id: attendee.id).first
  end
end
