class HomeController < ApplicationController
  use RateLimiter::Middleware, {limit: 100, period: 1.hour}, only: :index

  def index
    render plain: 'OK'
  end
end
