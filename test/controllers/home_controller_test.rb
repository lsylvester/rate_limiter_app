require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "GET index renders text 200" do
    get home_path
    assert_response 200
    assert_equal "OK", response.body
  end
end
