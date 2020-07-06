FROM ruby:2.7

ENV RAILS_ROOT /app
ENV RAILS_ENV='production'
ENV RACK_ENV='production' 

WORKDIR ${RAILS_ROOT}

COPY Gemfile Gemfile.lock ./
COPY ./gemfiles ./gemfiles

RUN gem install bundler:1.13.6
RUN bundle install

COPY . .

EXPOSE 9292

CMD bundle exec puma -t 2:5