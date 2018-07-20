require 'test_helper'

class RateLimiter::MiddlewareTest < ActiveSupport::TestCase

  setup do
    @app = -> env { [200, {}, [""]] }
    @middleware =  RateLimiter::Middleware.new(@app, limit: 10, period: 1.minute)
  end

  test "it should add headers for limit and remaining counts" do
    _, headers, _ = @middleware.call({})
    assert_equal "10", headers["X-RateLimit-Limit"]
    assert_equal "9", headers["X-RateLimit-Remaining"]
    assert_equal (Time.now + 60).to_i.to_s, headers["X-RateLimit-Reset"]

    _, headers, _ = @middleware.call({})

    assert_equal "8", headers["X-RateLimit-Remaining"]
  end

  test "it should throttle requests exceeding limit" do
    counter = RateLimiter::Counter.new("127.0.0.1")
    counter.with_connection do
      10.times{ counter.incr }
      counter.expire 14
    end

    status, headers, body = @middleware.call({"REMOTE_ADDR" => "127.0.0.1"})

    assert_equal 429, status
    assert_equal "Rate Limit Exceeded. Please retry in 14 seconds.", body.body

  end

end
