require 'test_helper'

class RateLimiter::StoreTest < ActiveSupport::TestCase

  test "connection with namespace" do
    RateLimiter::Counter.store.with_connection do |conn|
      assert_equal "test:rate_limiter", conn.namespace
    end
  end

end
