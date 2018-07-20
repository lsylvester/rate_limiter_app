module RateLimiter
  class RequestThrottler
    def initialize(identifer, limit:, period:)
      @indentifier = identifer
      @limit = limit
      @period = period
    end

    def perform
      ActiveSupport::Notifications.instrument 'throttle.rate_limiter', identifier: @indentifier, limit: @limit do |payload|
        @counter = Counter.new(@indentifier)
        @counter.incr_and_expire(@period)

        payload[:throttled] = throttled?
        payload[:count] = @counter.value
        payload[:expires] = @counter.expires_at
      end
    end

    delegate :expires_in, to: :@counter
    attr_reader :limit

    def remaining
      @limit - @counter.value
    end

    def throttled?
      @counter.exceeds?(@limit)
    end

    def reset
      @counter.expires_at.to_i
    end

    def throttled_response
      return unless throttled?
      ActionDispatch::Response.new(429, {}, "Rate Limit Exceeded. Please retry in #{expires_in.round} seconds.")
    end

    def response_headers
      {
        "X-RateLimit-Limit"     => limit.to_s,
        "X-RateLimit-Remaining" => remaining.to_s,
        "X-RateLimit-Reset"     => reset.to_s
      }
    end
  end
end
