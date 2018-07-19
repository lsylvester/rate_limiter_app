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

      counter = Counter.new(@store, request.remote_ip)
      counter.incr(expires_in: @options[:period])

      if counter.value > @options[:limit]
        response = ActionDispatch::Response.new(427, {}, "Rate Limit Exceeded. Please retry in #{counter.expires_in} seconds.")
      else
        response = ActionDispatch::Response.new(*@app.call(env))
      end
      response.headers["X-RateLimit-Limit"] = @options[:limit].to_s
      response.headers["X-RateLimit-Remaining"] = (@options[:limit] - counter.value).to_s

      response.to_a
    end
  end
end
