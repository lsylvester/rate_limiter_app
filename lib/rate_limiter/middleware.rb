require 'rate_limiter/store'

module RateLimiter
  class Middleware
    def initialize(app, identifier: :remote_ip.to_proc, **options)
      @app = app
      @options = options
      @identifier = identifier
    end

    attr_reader :store

    def call(env)
      request = ActionDispatch::Request.new(env)

      throttler = RequestThrottler.new(@identifier.call(request), **@options)
      throttler.perform

      status, headers, body = (throttler.throttled_response || @app.call(env)).to_a

      headers.merge!(throttler.response_headers)

      [status, headers, body]
    end
  end
end
