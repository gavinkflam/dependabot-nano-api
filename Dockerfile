FROM ruby:2.6.5-slim-buster

RUN \
  # Throw errors if Gemfile has been modified since Gemfile.lock
  bundle config --global frozen 1 && \
  # Update bunler
  gem install bundler:2.0.2 && \
  # Install dependencies for native extensions
  apt-get update && \
  apt-get install -y \
    build-essential && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

COPY . .

CMD ["bundle", "exec", "falcon", "serve", "-b", "http://0.0.0.0:3000"]
