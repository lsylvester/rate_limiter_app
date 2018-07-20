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

      status, headers, body = if throttler.throttled?
        ActionDispatch::Response.new(429, {}, "Rate Limit Exceeded. Please retry in #{throttler.expires_in.round} seconds.").to_a
      else
        @app.call(env)
      end

      headers.merge!(rate_limit_response_headers(throttler))

      [status, headers, body]
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
