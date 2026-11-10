require 'test_helper'

class AuthenticationTest < ApiTest
  test 'registration returns the v1 token and email contract' do
    json_request :post, '/v1/users', { user: { email: 'new@example.test', password: 'test-password-42' } }, token: nil
    assert_json_response 201
    assert_equal %w[auth_token email], json.keys.sort
    assert_equal 'new@example.test', json['email']
    assert_equal User.where(email: 'new@example.test').first.token, json['auth_token']
  end

  test 'invalid registration returns field errors' do
    json_request :post, '/v1/users', { user: { email: 'invalid', password: 'short' } }, token: nil
    assert_json_response 422
    assert json.key?('email')
    assert json.key?('password')
  end

  test 'login rotates the token and invalidates the previous token' do
    previous = @user.token
    json_request :post, '/v1/users/sign_in', { user: { email: @user.email, password: 'test-password-42' } }, token: nil
    assert_json_response 200
    assert_equal %w[auth_token email success], json.keys.sort
    assert_equal true, json['success']
    refute_equal previous, json['auth_token']
    assert_equal @user.reload.token, json['auth_token']
    get api_path('/v1/events', token: previous)
    assert_json_response 401
  end

  test 'incorrect passwords and unknown emails share a failure response' do
    [@user.email, 'unknown@example.test'].each do |email|
      json_request :post, '/v1/users/sign_in', { user: { email: email, password: 'incorrect' } }, token: nil
      assert_json_response 401
      assert_equal({ 'success' => false, 'message' => 'Error with your login or password' }, json)
    end
  end

  test 'missing login credentials return a JSON validation response' do
    json_request :post, '/v1/users/sign_in', {}, token: nil
    assert_json_response 422
    assert_equal({ 'success' => false, 'message' => 'missing user parameter' }, json)
  end

  test 'missing and invalid client keys are rejected before token checks' do
    [nil, 'incorrect'].each do |key|
      get api_path('/v1/events', key: key, token: nil)
      assert_json_response 401
      assert_equal({ 'message' => 'Invalid Client Key' }, json)
    end
  end

  test 'missing and invalid tokens are rejected' do
    [nil, 'incorrect'].each do |token|
      get api_path('/v1/events', token: token)
      assert_json_response 401
      assert_equal({ 'message' => 'Invalid token' }, json)
    end
  end

  test 'registration and login require a client key' do
    ['/v1/users', '/v1/users/sign_in'].each do |path|
      json_request :post, path, { user: { email: @user.email, password: 'test-password-42' } }, key: nil, token: nil
      assert_json_response 401
      assert_equal({ 'message' => 'Invalid Client Key' }, json)
    end
  end
end
