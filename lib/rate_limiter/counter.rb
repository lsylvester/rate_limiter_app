module RateLimiter
  class Counter
    def initialize(key)
      @key = key
    end

    attr_reader :value, :store

    def incr
      @value = connection.incr(@key)
    end

    def expires_in
      connection.expires_in(@key)
      # store.with_connection do |redis|
      #   ttl = redis.pttl(@key)
      #   ttl.to_f / 1000 if ttl > 0
      # end
    end

    def expires_in=(value)
      connection.expire(@key, value.to_i)
      # store.with_connection do |redis|
      #  redis.expire(@key, value.to_i)
      # end
    end

    def expires_at
      expires_in.try{ |seconds| Time.now + seconds }
    end

    def exceeds?(limit)
      @value > limit
    end

    def with_connection
      store.with_connection do |connection|
        @connection = connection
        yield
      ensure
        @connection = nil
      end
    end

    def connection
      @connection || raise("No connection. Wrap this in a with_connection block")
    end

    def store
      Store.instance
    end
  end
end
