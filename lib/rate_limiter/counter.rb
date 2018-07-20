module RateLimiter
  class Counter
    def initialize(key)
      @key = key
    end

    attr_reader :value, :store

    def incr
      @value = connection.incr(@key)
    end

    def incr_and_expire(expiry)
      with_connection do
        incr
        expire(expiry) unless expires?
      end
    end

    def expires_in
      expires_at - Time.now
    end

    def expire(value)
      connection.expire(@key, value.to_i)
      @expires_at = Time.now + value.to_i
    end

    def expires_at
      return @expires_at if defined?(@expires_at)
      @expires_at = connection.expires_in(@key).try{ |duration| Time.now + duration}
    end

    alias :expires? :expires_at

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

    class NoConnectionError < StandardError; end

    def connection
      @connection || raise(NoConnectionError, "Wrap this call in a with_connection block to check out a connection from the redis pool")
    end

    def store
      Store.instance
    end
  end
end
