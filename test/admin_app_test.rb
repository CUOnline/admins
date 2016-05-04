require_relative '../admin_app'
require 'minitest/autorun'
require 'minitest/rg'
require 'mocha/mini_test'
require 'rack/test'

# Turn on SSL for all requests
class Rack::Test::Session
  def default_env
    { 'rack.test' => true,
      'REMOTE_ADDR' => '127.0.0.1',
      'HTTPS' => 'on'
    }.merge(@env).merge(headers_for_env)
  end
end

class AdminAppTest < Minitest::Test

  include Rack::Test::Methods

  def app
    AdminApp
  end

  def setup
    # Log in
    env 'rack.session', {'user_id' => '123', 'user_roles' => ['AccountAdmin']}
  end

  def test_get
    sub_accounts = [{
      'name' => 'School of Busniess',
      'id' => 123
    }, {
      'name' => 'School of Medicine',
      'id' => 456
    }]
    app.any_instance.expects(:canvas_api).once.returns(sub_accounts)

    get '/'
    assert_equal 200, last_response.status
    sub_accounts.each do |s|
      assert_match /#{s['name']}/, last_response.body
      assert_match /#{s['id']}/, last_response.body
    end
  end

  def test_get_admins
    account_id = 1
    admins = [{
      'user' => {
        'id' => 123,
        'name' => 'Test Guy',
        'sis_user_id' => 456,
      },
      'role' => 'Enrollment Manager'
    }, {
      'user' => {
        'id' => 789,
        'name' => 'Test Gal',
        'sis_user_id' => 012,
      },
      'role' => 'Admin'
    }]

    app.any_instance.expects(:canvas_api)
                         .with(:get, "accounts/#{account_id}/admins")
                         .returns(admins)

    get "/admins/#{account_id}"
    assert_equal 200, last_response.status
    admins.each do |a|
      assert_match /#{a['user']['name']}/, last_response.body
      assert_match /#{a['user']['sis_user_id']}/, last_response.body
      assert_match /#{a['role']}/, last_response.body
    end
  end

  def test_get_user
    user_id = 1
    user_email = 'test@gmail.com'
    user_last_activity = 'January 01, 1970'
    app.any_instance.expects(:canvas_api)
                         .with(:get, "/users/#{user_id}/profile")
                         .returns({'primary_email' => user_email})

    app.any_instance.expects(:canvas_api)
                         .with(:get, "/users/#{user_id}/page_views")
                         .returns([{'created_at' => user_last_activity}])

    get "/user/#{user_id}"
    assert_equal 200, last_response.status
    assert_match /#{user_email}/, last_response.body
    assert_match /#{user_last_activity}/, last_response.body
  end

  def test_get_user_missing_data
    user_id = 1
    app.any_instance.expects(:canvas_api)
                         .with(:get, "/users/#{user_id}/profile")
                         .returns({})

    app.any_instance.expects(:canvas_api)
                         .with(:get, "/users/#{user_id}/page_views")
                         .returns([{}])

    get "/user/#{user_id}"
    assert_equal 200, last_response.status
    assert_match /N\/A/, last_response.body
    assert_match /N\/A/, last_response.body
  end

end
