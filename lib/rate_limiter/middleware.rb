require 'rate_limiter/store'

module RateLimiter
  class Middleware

    

    def initialize(app, identifier: :remote_ip.to_proc, limit:, period:)
      @app = app
      @limit = limit
      @period = period
      @identifier = identifier
    end

    def call(env)
      request = ActionDispatch::Request.new(env)

      throttler = RequestThrottler.new(@identifier.call(request), limit: @limit, period: @period)
      throttler.perform

      status, headers, body = (throttler.throttled_response || @app.call(env)).to_a

      headers.merge!(throttler.response_headers)

      [status, headers, body]
    end
  end
end
