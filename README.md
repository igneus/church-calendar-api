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

## Installation and running

### Running locally

In case you want to run your own instance of the API,
either for development or to make your own public instance of the service:

1. install dependencies using Bundler
   `$ bundle install`
2. start application by `$ rackup`

### Production deployment

Probably the easiest production deployment is to Heroku.
The application works as is, you only need to create a new application
in your Heroku dashboard and push the code.

Typical reasons for running your own instance include:

* availability/reliability requirements (the [reference instance][calapi] is self-hosted by the author and only maintained as free time permits)
* very high traffic expected
* custom calendar data that cannot be released as open-source (e.g. because it is copyrighted by the diocese)

Anyone intending to run a public instance is kindly asked
to update contact information displayed on the web app.

## Configuration

### Calendar data

In the [data](/data) directory you will only find data for the
General Roman Calendar in English.
More data files (General Roman Calendar in Latin, calendars
of the dioceses of the Czech Republic), together with a description
of the data format, can be found in the repository of the
[calendarium-romanum][caro_data] gem.

In order to add a new calendar:

1. put it's data file(s) in the `data` directory
2. create a new record in `config/calendars.yml`

For a complete example configuration with several calendars,
including calendars composed of several "layered" data files,
see [configuration used at the author's instance of the API][calapicz_config].

## License

GNU/LGPL 3 or later

[calapi]: http://calapi.inadiutorium.cz
[caro]: http://github.com/igneus/calendarium-romanum
[caro_data]: https://github.com/igneus/calendarium-romanum/tree/master/data
[calapicz_config]: https://github.com/igneus/church-calendar-api/blob/calapi.inadiutorium.cz/config/calendars.yml
