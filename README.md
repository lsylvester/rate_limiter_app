# Rate Limiter App

[![Build Status](https://travis-ci.com/lsylvester/rate_limiter_app.svg?branch=master)](https://travis-ci.com/lsylvester/rate_limiter_app) [![Maintainability](https://api.codeclimate.com/v1/badges/5a63952bce55a8b3b1a5/maintainability)](https://codeclimate.com/github/lsylvester/rate_limiter_app/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/5a63952bce55a8b3b1a5/test_coverage)](https://codeclimate.com/github/lsylvester/rate_limiter_app/test_coverage)

This is a demo application that implements a rate limiter.

A live demo of this app can be seen at https://rate-limiter-app-demo.herokuapp.com

## Getting started

This application as two system dependencies.

* Ruby 2.5.1
* Redis

You will need this installed before you can begin.

To get started:

Clone the repository:

    git clone https://github.com/lsylvester/rate_limiter_app.git
    cd rate_limiter_app

And run the setup script

    ./bin/setup

Then start up the server

    ./bin/rails server

And visit

    http://localhost:3000/

You will see OK for the first 100 times within the hour, but after that your responses will be rate limited.

## Configuring Redis

Redis is configured per environement via the ./config/redis.yml file.

There are two specials keys in this file:

* `:pool` - the values under this key are used to configure the ConnectionPool for redis. See https://github.com/mperham/connection_pool#usage for details on valid options.
* `:namespace` - this configures the namespace to be used by the redis connection. See https://github.com/resque/redis-namespace#redis-namespace for details.

All other options are passed directly into the redis instance. If these are not set, redis can be configured via the environment varaiable `REDIS_URL` or the default options will be used.
