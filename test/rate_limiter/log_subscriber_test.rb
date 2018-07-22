require 'test_helper'
require 'active_support/log_subscriber/test_helper'

class RateLimiter::LogSubscriberTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper

  def setup
    @app = -> env { [200, {}, [""]] }
    @middleware =  RateLimiter::Middleware.new(@app, limit: 10, period: 1.minute)
    super
    RateLimiter::LogSubscriber.attach_to(:rate_limiter)
  end

  def teardown
    super
    RateLimiter::LogSubscriber.log_subscribers.pop
    ActiveSupport::LogSubscriber.instance_variable_set(:@logger, nil)
  end

  test "logging a permited request" do
    @middleware.call({"REMOTE_ADDR" => "127.0.0.1"})
    assert_equal 1, @logger.logged(:debug).size
    assert_match(/Allowed/, @logger.logged(:debug).last)
  end

  test "logging a rejected request" do
    counter = RateLimiter::Counter.new("127.0.0.1")

    counter.with_connection do
      10.times{ counter.incr }
    end

    @middleware.call({"REMOTE_ADDR" => "127.0.0.1"})
    assert_equal 1, @logger.logged(:info).size
    assert_match(/Throttled/, @logger.logged(:info).last)
  end

  protected

  def set_logger(logger)
    ActiveSupport::LogSubscriber.instance_variable_set(:@logger, logger)
  end
end
