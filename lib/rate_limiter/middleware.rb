require 'rate_limiter/store'

module RateLimiter
  class Middleware
    def initialize(app, **options)
      @app = app
      @options = options
    end

    attr_reader :store

    def call(env)
      request = ActionDispatch::Request.new(env)

      throttler = RequestThrottler.new(request, **@options)
      throttler.perform

      if throttler.throttled?
        response = ActionDispatch::Response.new(429, {}, "Rate Limit Exceeded. Please retry in #{throttler.expires_in.round} seconds.")
      else
        response = ActionDispatch::Response.new(*@app.call(env))
      end

      response.headers.merge!(rate_limit_response_headers(throttler))
      response.to_a
    end

    protected

    def rate_limit_response_headers(throttler)
      {
        "X-RateLimit-Limit"     => throttler.limit.to_s,
        "X-RateLimit-Remaining" => throttler.remaining.to_s,
        "X-RateLimit-Reset"     => throttler.reset.to_s
      }
    end
  end
end
