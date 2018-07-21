require 'rate_limiter/store'

module RateLimiter
  class Middleware
    # This middleware provides rate limiting. It is configured with the following options:
    #
    # * `:limit`      - The number of requests to be allowed within the period
    # * `:period`     - Number of seconds for the rate limited window.
    # * `:identifier` - A `Proc` that accepts the `ActionDispatch::Request` and returns a unique string for the requester . By default it extracts the `remote_ip`
    #
    # For example usage, see the HomeController.

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
