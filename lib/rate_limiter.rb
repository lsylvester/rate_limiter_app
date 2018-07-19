module RateLimiter
  extend ActiveSupport::Autoload

  autoload :Counter
  autoload :Middleware
  autoload :Store
end
