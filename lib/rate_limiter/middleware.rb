module RateLimiter
  class Middleware
    def initialize(app, options)
      @app = app
      @options = options
      @store = Store.new
    end

    def call(env)
      request = ActionDispatch::Request.new(env)

      count = @store.incr(request.remote_ip)

      response = ActionDispatch::Response.new(*@app.call(env))

      response.to_a
    end
  end
end
