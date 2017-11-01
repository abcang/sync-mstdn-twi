FROM ruby:alpine

MAINTAINER ABCanG <abcang1015@gmail.com>

RUN apk add --no-cache --virtual build-dependencies build-base

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile /app/
COPY Gemfile.lock /app/
RUN bundle install --deployment

COPY . /app

CMD ["ruby", "./main.rb"]
