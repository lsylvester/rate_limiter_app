require 'test_helper'

class RateLimiter::StoreTest < ActiveSupport::TestCase

  test "connection with namespace" do
    RateLimiter::Store.instance.with_connection do |conn|
      assert_equal "test:rate_limiter", conn.namespace
      assert_instance_of Redis::Namespace, conn
    end
  end

end
