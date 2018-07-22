module RateLimiter
  class LogSubscriber < ActiveSupport::LogSubscriber
    def throttle(event)
      if event.payload[:throttled]
        action = "Throttled"
        severity = :info
      else
        action = "Allowed"
        severity = :debug
      end
      send severity, "[RateLimiter] #{action} request for #{event.payload[:identifier]} (#{event.payload[:count]}/#{event.payload[:limit]}). Expires at #{event.payload[:expires] }. (#{event.duration.round(1)}ms)"
    end
  end
end
