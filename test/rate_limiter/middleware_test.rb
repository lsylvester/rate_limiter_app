require 'test_helper'

class RateLimiter::MiddlewareTest < ActiveSupport::TestCase

  setup do
    @app = -> env { [200, {}, [""]] }
    @middleware =  RateLimiter::Middleware.new(@app, limit: 10, period: 1.minute)
  end

  teardown do
    @middleware.store.clear
  end

  test "it should add headers for limit and remaining counts" do
    _, headers, _ = @middleware.call({})
    assert_equal "10", headers["X-RateLimit-Limit"]
    assert_equal "9", headers["X-RateLimit-Remaining"]

    _, headers, _ = @middleware.call({})

    assert_equal "8", headers["X-RateLimit-Remaining"]
  end

  test "it should throttle requests exceeding limit" do
    10.times{ @middleware.store.incr("127.0.0.1", expires_in: 14) }

    status, headers, body = @middleware.call({"REMOTE_ADDR" => "127.0.0.1"})

    assert_equal 427, status
    assert_equal "Rate Limit Exceeded. Please retry in 14 seconds.", body.body

  end

end
