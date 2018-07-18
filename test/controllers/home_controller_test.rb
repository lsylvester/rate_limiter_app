require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "GET index renders text OK" do
    get home_path
    assert_response 200
    assert_equal "OK", response.body
  end


end
