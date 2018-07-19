module RateLimiter
  class Counter
    def initialize(store, key)
      @store, @key = store, key
    end

    attr_reader :value

    def incr(expires_in:)
      @value = @store.incr(@key, expires_in: expires_in)
    end

    def expires_in
      @store.with_connection do |redis|
        redis.ttl(@key)
      end
    end
  end
end
