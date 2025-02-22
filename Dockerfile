FROM ruby:2.7.5-bullseye

WORKDIR /app
RUN  apt-get update && apt-get -y install lsb-release
#
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    apt-get update && apt-get -y install postgresql postgresql-client-14

RUN sh -c 'echo "local   all             all                                     trust" > /etc/postgresql/$(ls /etc/postgresql)/main/pg_hba.conf' && \
    service postgresql start && \
    psql -U postgres -c 'CREATE DATABASE "niceql-test"'

RUN  gem install bundler -v 2.4.22

COPY lib/rails_sql_prettifier/version.rb /app/lib/rails_sql_prettifier/version.rb
COPY rails_sql_prettifier.gemspec /app/
COPY Gemfil* /app/
#
RUN bundle install