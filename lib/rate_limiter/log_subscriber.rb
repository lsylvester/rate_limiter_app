module RateLimiter
  class LogSubscriber < ActiveSupport::LogSubscriber
    def throttle(event)
      if event.payload[:throttled]
        info "[RateLimiter] Throttled request for #{event.payload[:identifier]} (#{event.payload[:count]}/#{event.payload[:limit]}). Expires at #{event.payload[:expires]}"
      else
        debug "[RateLimiter] Allowed request for #{event.payload[:identifier]} (#{event.payload[:count]}/#{event.payload[:limit]}). Expires at #{event.payload[:expires]}"
      end
    end

    def logger
      Rails.logger
    end
  end
end
