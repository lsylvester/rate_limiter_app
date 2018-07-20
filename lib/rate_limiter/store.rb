module RateLimiter
  class Store
    include Singleton


    class_attribute :config, default: Rails.application.config_for(:redis).symbolize_keys

    def initialize(config=self.class.config)
      config[:size] ||= ENV.fetch("RAILS_MAX_THREADS") { 5 }.to_i
      @connection_pool = ConnectionPool.new(size: config[:size]){ ConnectionDelegate.new(build_client(config)) }
    end

    def with_connection
      @connection_pool.with{ |conn| yield conn }
    end

    def incr(key)
      with_connection do |conn|
        conn.incr(key)
      end
    end

    def clear
      with_connection do |conn|
        keys = conn.keys("*")
        conn.del(*keys) unless keys.empty?
      end
    end

    class ConnectionDelegate
      def initialize(redis)
        @redis = redis
      end

      def expires_in(key)
        ttl = @redis.pttl(key)
        ttl.to_f / 1000 if ttl > 0
      end

      delegate_missing_to :@redis
    end

    protected

    def build_client(namespace: nil, **options)
      namespace = namespace ? "#{namespace}:rate_limiter" : "rate_limiter"
      client = Redis.new(options)
      Redis::Namespace.new(namespace, :redis => client)
    end

  end
end
