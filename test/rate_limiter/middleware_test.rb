require 'test_helper'
require 'rate_limiter/middleware'

class RateLimiter::MiddlewareTest < ActiveSupport::TestCase

  setup do
    @app = -> env { [200, {}, [""]] }
    @middleware =  RateLimiter::Middleware.new(@app, limit: 10)
  end

  test "it should add headers for limit and remaining counts" do
    _, headers, _ = @middleware.call({})
    assert_equal "10", headers["X-RateLimit-Limit"]
    assert_equal "9", headers["X-RateLimit-Remaining"]

    _, headers, _ = @middleware.call({})

    assert_equal "8", headers["X-RateLimit-Remaining"]
  ensure
    Redis.new.flushdb
  end

end
