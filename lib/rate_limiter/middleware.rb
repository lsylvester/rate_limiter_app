require 'rate_limiter/store'

module RateLimiter
  class Middleware
    def initialize(app, limit:, period:)
      @app = app
      @limit = limit
      @period = period
      @store = Store.new
    end

    attr_reader :store

    def call(env)
      request = ActionDispatch::Request.new(env)

      counter = Counter.new(@store, request.remote_ip)
      counter.incr
      counter.expires_in ||= @period

      if counter.exceeds?(@limit)
        response = ActionDispatch::Response.new(429, {}, "Rate Limit Exceeded. Please retry in #{counter.expires_in.round} seconds.")
      else
        response = ActionDispatch::Response.new(*@app.call(env))
      end
      response.headers.merge!(rate_limit_response_headers(counter))

      response.to_a
    end

    protected

    def rate_limit_response_headers(counter)
      {
        "X-RateLimit-Limit"     => @limit.to_s,
        "X-RateLimit-Remaining" => (@limit - counter.value).to_s,
        "X-RateLimit-Reset"     => counter.expires_at.to_i.to_s
      }
    end
  end
end
