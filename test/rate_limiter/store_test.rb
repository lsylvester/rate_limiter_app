require 'test_helper'
require 'rate_limiter/store'

class RateLimiter::StoreTest < ActiveSupport::TestCase

  test "connection with namespace" do
    RateLimiter::Store.new(namespace: "foobar").with_connection do |conn|
      assert_equal "foobar:rate_limiter", conn.namespace
      assert_instance_of Redis::Namespace, conn
    end
  end

  test "incr" do
    store = RateLimiter::Store.new(namespace: "test")
    result = store.incr('key')
    assert_equal 1, result

    result = store.incr('key')
    assert_equal 2, result
  ensure
    store.clear
  end

end
