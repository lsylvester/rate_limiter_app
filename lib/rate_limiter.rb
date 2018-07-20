module RateLimiter
  extend ActiveSupport::Autoload

  autoload :Counter
  autoload :LogSubscriber
  autoload :Middleware
  autoload :RequestThrottler
  autoload :Store

  LogSubscriber.attach_to :rate_limiter

end
