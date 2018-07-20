module RateLimiter
  class RequestThrottler
    def initialize(request, limit:, period:)
      @request = request
      @limit = limit
      @period = period
    end

    def perform
      ActiveSupport::Notifications.instrument 'throttle.rate_limiter', identifier: @request.remote_ip, limit: @limit do |payload|
        @counter = Counter.new(Store.new, @request.remote_ip)
        @counter.incr
        @counter.expires_in ||= @period

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
  end
end
