FROM dependabot/dependabot-core:0.113.24

RUN \
  # Throw errors if Gemfile has been modified since Gemfile.lock
  bundle config --global frozen 1 && \
  # Update bunler
  gem install bundler:2.0.2

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

COPY . .

CMD ["bundle", "exec", "falcon", "serve", "-b", "http://0.0.0.0:3000"]
