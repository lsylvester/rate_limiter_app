require 'test_helper'
require 'rate_limiter/store'

class RateLimiter::StoreTest < ActiveSupport::TestCase

  test "connection with namespace" do
    RateLimiter::Store.new(namespace: "foobar").with_connection do |conn|
      assert_equal "foobar", conn.namespace
      assert_instance_of Redis::Namespace, conn
    end
  end

  test "connection without namespace" do
    RateLimiter::Store.new({}).with_connection do |conn|
      assert_instance_of Redis, conn
    end
  end

end
