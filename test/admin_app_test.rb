require_relative '../admin_app'

require 'minitest/autorun'
require 'minitest/rg'
require 'mocha/mini_test'
require 'rack/test'
require 'webmock/minitest'

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

  def login(session_params = {})
    defaults = {
      'user_id' => '123',
      'user_roles' => ['AccountAdmin'],
      'user_email' => 'test@example.com'
    }

    env 'rack.session', defaults.merge(session_params)
  end

  def setup
    WebMock.enable!
    WebMock.disable_net_connect!(allow_localhost: true)
    app.set :api_cache, false
  end

  def test_get
    token = '1a2b3c'
    account_id = '123'
    sub_accounts = [{
      'name' => 'School of Busniess',
      'id' => 123
    }, {
      'name' => 'School of Medicine',
      'id' => 456
    }]
    response = OpenStruct.new(:body => sub_accounts)

    app.settings.stubs(:canvas_token).returns(token)
    app.settings.stubs(:canvas_account_id).returns(account_id)
    stub_request(:get, /accounts\/#{account_id}\/sub_accounts\?access_token=#{token}&per_page=100/)
      .to_return(:body => sub_accounts, :headers => {'Content-Type' => 'application/json'})

    login
    get '/'

    assert_equal 200, last_response.status
    sub_accounts.each do |s|
      assert_match /#{s['name']}/, last_response.body
      assert_match /#{s['id']}/, last_response.body
    end
  end

  def test_get_unauthenticated
    get '/'
    assert_equal 302, last_response.status
    follow_redirect!
    assert_equal '/canvas-auth-login', last_request.path
  end

  def test_get_unauthorized
    login({'user_roles' => ['StudentEnrollment']})
    get '/'
    assert_equal 302, last_response.status
    follow_redirect!
    assert_equal '/unauthorized', last_request.path
  end

  def test_get_admins
    sub_account_id = 999
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

    profile_responses = [{'profile1' => 'data'}, {'profile2' => 'data'}].map(&:to_json)
    page_view_responses = [{'page_view_1' => 'data'}, {'page_view_2' => 'data'}].map(&:to_json)
    profile_links = ['profile_link_1', 'profile_link_2']
    email_links = ['email_link_1', 'email_link_2']
    timestamps = ['timestamp_1', 'timestamp_2']

    stub_request(:get, /accounts\/#{sub_account_id}\/admins/)
      .to_return(:body => admins.to_json, :headers => {'Content-Type' => 'application/json'})

    admins.each_with_index do |a, i|
      stub_request(:get, /users\/#{a['user']['id']}\/profile/)
        .to_return(:body => profile_responses[i], :headers => {'Content-Type' => 'application/json'})
      stub_request(:get, /users\/#{a['user']['id']}\/page_views/)
        .to_return(:body => page_view_responses[i], :headers => {'Content-Type' => 'application/json'})

      app.any_instance.expects(:profile_link)
                      .with(a['user']['id'], a['user']['name'])
                      .returns(profile_links[i])
      app.any_instance.expects(:email_link_from_response)
                      .with(instance_of(Faraday::Response))
                      .returns(email_links[i])
      app.any_instance.expects(:last_activity_from_response)
                      .with(instance_of(Faraday::Response))
                      .returns(timestamps[i])
    end

    login
    get "/admins/#{sub_account_id}"

    assert_equal 200, last_response.status
    admins.each_with_index do |a, i|
      assert_match /#{profile_links[i]}/, last_response.body
      assert_match /#{email_links[i]}/, last_response.body
      assert_match /#{timestamps[i]}/, last_response.body
      assert_match /#{a['user']['id']}/, last_response.body
      assert_match /#{a['user']['sis_user_id']}/, last_response.body
      assert_match /#{a['role']}/, last_response.body
    end
  end

  def test_get_admins_unauthenticated
    get '/'
    assert_equal 302, last_response.status
    follow_redirect!
    assert_equal '/canvas-auth-login', last_request.path
  end

  def test_get_admins_unauthorized
    login({'user_roles' => ['StudentEnrollment']})
    get '/'
    assert_equal 302, last_response.status
    follow_redirect!
    assert_equal '/unauthorized', last_request.path
  end
end
