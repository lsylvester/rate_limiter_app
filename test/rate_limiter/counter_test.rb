require 'test_helper'

class RateLimiter::CounterTest < ActiveSupport::TestCase

  setup do
    @counter = RateLimiter::Counter.new( "count_key")
  end

  test "incr would increase the value" do
    @counter.with_connection do
      @counter.incr
      assert_equal 1, @counter.value

      @counter.incr
      assert_equal 2, @counter.value
    end
  end

  test "should set and read the expires_in" do
    @counter.with_connection do
      @counter.incr
      @counter.expire 10
      assert_equal 10, @counter.expires_in.round
    end
  end


end
