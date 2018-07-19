require 'test_helper'

class RateLimiter::StoreTest < ActiveSupport::TestCase

  setup do
    @store = RateLimiter::Store.new(namespace: "test")
  end

  teardown do
    @store.clear
  end

  test "connection with namespace" do
    RateLimiter::Store.new(namespace: "foobar").with_connection do |conn|
      assert_equal "foobar:rate_limiter", conn.namespace
      assert_instance_of Redis::Namespace, conn
    end
  end

  test "incr" do
    result = @store.incr('key', expires_in: 20)
    assert_equal 1, result

    result = @store.incr('key', expires_in: 20)
    assert_equal 2, result
  end

  test "incr with expiry should set the expiry if the key is new" do
    @store.incr('key', expires_in: 4)
    @store.with_connection do |redis|
      assert_equal 4, redis.ttl("key")
    end

    @store.incr('key', expires_in: 10)
    @store.with_connection do |redis|
      assert_equal 4, redis.ttl("key")
    end
  end

end
