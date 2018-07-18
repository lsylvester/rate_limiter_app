require 'rate_limiter/middleware'

class HomeController < ApplicationController
  use RateLimiter::Middleware, {}, only: :index

  def index
    render plain: 'OK'
  end
end
