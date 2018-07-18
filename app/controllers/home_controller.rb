require 'rate_limiter/middleware'

class HomeController < ApplicationController
  use RateLimiter::Middleware, {limit: 100}, only: :index

  def index
    render plain: 'OK'
  end
end
