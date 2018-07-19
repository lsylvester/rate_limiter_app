require 'test_helper'

class RateLimiter::CounterTest < ActiveSupport::TestCase

  setup do
    @counter = RateLimiter::Counter.new(RateLimiter::Store.new, "count_key")
  end

  teardown do
    @counter.store.clear
  end

  test "incr would increase the value" do
    @counter.incr(expires_in: 10)
    assert_equal 1, @counter.value

    @counter.incr(expires_in: 10)
    assert_equal 2, @counter.value
  end

  test "incr should set the expiry on inital entry" do
    @counter.incr(expires_in: 10)
    assert_equal 10, @counter.expires_in
    @counter.incr(expires_in: 20)
    assert_equal 10, @counter.expires_in
  end


end
