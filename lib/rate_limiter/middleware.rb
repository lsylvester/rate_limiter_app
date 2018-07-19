require 'rate_limiter/store'

module RateLimiter
  class Middleware
    def initialize(app, options)
      @app = app
      @options = options
      @store = Store.new
    end

    attr_reader :store

    def call(env)
      request = ActionDispatch::Request.new(env)

      count = @store.incr(request.remote_ip, expires_in: @options[:period])

      ttl = @store.with_connection do |redis|
        redis.ttl(request.remote_ip)
      end

      if count > @options[:limit]
        response = ActionDispatch::Response.new(427, {}, "Rate Limit Exceeded. Please retry in #{ttl} seconds.")
      else
        response = ActionDispatch::Response.new(*@app.call(env))
      end
      response.headers["X-RateLimit-Limit"] = @options[:limit].to_s
      response.headers["X-RateLimit-Remaining"] = (@options[:limit] - count).to_s

      response.to_a
    end
  end
end
