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

      count = @store.incr(request.remote_ip)

      response = ActionDispatch::Response.new(*@app.call(env))

      response.headers["X-RateLimit-Limit"] = @options[:limit].to_s
      response.headers["X-RateLimit-Remaining"] = (@options[:limit] - count).to_s

      response.to_a
    end
  end
end
