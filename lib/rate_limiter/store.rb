module RateLimiter
  class Store

    class_attribute :config, default: Rails.application.config_for(:redis).symbolize_keys

    def initialize(config=self.class.config)
      config[:size] ||= ENV.fetch("RAILS_MAX_THREADS") { 5 }.to_i
      @connection_pool = ConnectionPool.new(size: config[:size]){ build_client(config) }
    end

    def with_connection
      @connection_pool.with{ |conn| yield conn }
    end

    def incr(key, expires_in:)
      with_connection do |conn|
        conn.incr(key).tap do
          ttl = conn.ttl(key)
          if ttl < 0
            conn.expire key, expires_in.to_i
          end
        end
      end
    end

    def clear
      with_connection do |conn|
        keys = conn.keys("*")
        conn.del(*keys) unless keys.empty?
      end
    end

    protected

    def build_client(namespace: nil, **options)
      namespace = namespace ? "#{namespace}:rate_limiter" : "rate_limiter"
      client = Redis.new(options)
      Redis::Namespace.new(namespace, :redis => client)
    end

  end
end
