require_relative '../helpers'

require 'minitest/autorun'
require 'minitest/rg'

class HelpersTest < Minitest::Test

  include Rack::Test::Methods
  include Helpers

  def test_profile_link
    self.stubs(:settings).returns(OpenStruct.new(:canvas_url => 'https://canvasurl.com'))
    expected = "<a href='https://canvasurl.com/users/123' target='_blank'>Name Namerson</a>"
    assert_equal expected, profile_link(123, 'Name Namerson')

    self.stubs(:settings).returns(OpenStruct.new(:canvas_url => 'https://ucdenver.edu'))
    expected = "<a href='https://ucdenver.edu/users/456' target='_blank'>Foo McFly</a>"
    assert_equal expected, profile_link(456, 'Foo McFly')
  end

  def test_email_link_from_response
    response = OpenStruct.new(:body => {'primary_email' => 'foo@example.com'})
    expected = "<a href='mailto:foo@example.com'>foo@example.com</a>"
    assert_equal expected, email_link_from_response(response)
  end

  def test_email_link_from_response_missing_data
    response = OpenStruct.new(:body => {})
    assert_equal 'N/A', email_link_from_response(response)
  end

  def test_last_activity_from_response
    response = OpenStruct.new(:body => [
      {'created_at' => '2016-10-10T20:20:22Z'},
      {'created_at' => '2015-11-11T20:20:22Z'}
    ])
    assert_equal 'October 10, 2016', last_activity_from_response(response)

    response = OpenStruct.new(:body => [
      {'created_at' => '2015-11-11T20:20:22Z'},
      {'created_at' => '2016-10-20T20:20:22Z'}
    ])
    assert_equal 'October 20, 2016', last_activity_from_response(response)
  end

  def test_last_activity_from_response_missing_data
    response = OpenStruct.new(:body => {})
    assert_equal 'N/A', last_activity_from_response(response)
  end

end
