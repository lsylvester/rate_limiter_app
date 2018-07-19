module RateLimiter
  class Counter
    def initialize(store, key)
      @store, @key = store, key
    end

    attr_reader :value, :store

    def incr
      @value = @store.incr(@key)
    end

    def expires_in
      @store.with_connection do |redis|
        ttl = redis.ttl(@key)
        ttl if ttl > 0
      end
    end

    def expires_in=(value)
      @store.with_connection do |redis|
        redis.expire(@key, value.to_i)
      end
    end

    def expires_at
      expires_in.try{ |duration| Time.now + duration }
    end

    def exceeds?(limit)
      @value > limit
    end
  end
end
