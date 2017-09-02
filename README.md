# Church Calendar API

[![Build Status](https://travis-ci.org/igneus/church-calendar-api.svg?branch=master)](https://travis-ci.org/igneus/church-calendar-api)

Browse Roman Catholic liturgical calendar through a web interface
or obtain it's data in JSON format through an API.

Powered by
[calendarium-romanum][caro] and
grape.

## Explore it on-line

Church Calendar API is a more or less RESTful read-only JSON API.

API documentation with URI examples and live links to API endpoints:
http://calapi.inadiutorium.cz/api-doc

## Running locally

1. install dependencies using Bundler
   `$ bundle install`
2. start application by `$ rackup`

## Running your own instance on Heroku

The application works as is, you only need to create a new application
in your Heroku dashboard and push the code.

Typical reasons for running your own instance include:

* availability/reliability requirements (the [reference instance][calapi] is self-hosted by the author and only maintained as free time permits)
* very high traffic expected
* custom calendar data that cannot be released as open-source (e.g. because it is copyrighted by the diocese)

## Adding custom data

In order to add a new calendar:

1. put it's data file(s) in the `data` directory
2. create a new record in `config/calendars.yml`

## Client libraries

* Ruby: [calendarium-romanum-remote][caro_remote]

## License

GNU/LGPL 3 or later

[calapi]: http://calapi.inadiutorium.cz
[caro]: http://github.com/igneus/calendarium-romanum
[caro_data]: https://github.com/igneus/calendarium-romanum/tree/master/data
[caro_remote]: https://github.com/igneus/calendarium-romanum-remote
