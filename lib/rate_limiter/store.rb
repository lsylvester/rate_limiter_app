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

    def incr(key)
      with_connection do |conn|
        conn.incr(key)
      end
    end

    protected

    def build_client(namespace: nil, **options)
      client = Redis.new(options)
      if namespace
        Redis::Namespace.new(namespace, :redis => client)
      else
        client
      end
    end

  end
end
