# Church Calendar API

Browse Roman Catholic liturgical calendar through a web interface
or obtain it's data in JSON format through an API.

Powered by
[calendarium-romanum][caro] and
grape.

## Explore it on-line

Church Calendar API is a more or less RESTful API.
It is queried by HTTP requests where requested resources are described
by the URL path.
It responds with JSON documents.

Documentation with examples and live links:
http://calapi.inadiutorium.cz/api-doc

## Installation and running

In case you want to run your own instance of the API,
either for development or to make your own public instance of the service:

1. install dependencies using Bundler
   `$ bundle install`
2. manually install [calendarium-romanum][caro] (once it is released,
   this step won't be necessary)
3. start application by `$ rackup`

## License

GNU/LGPL 3 or later

[caro]: http://github.com/igneus/calendarium-romanum
