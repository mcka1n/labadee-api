FROM ruby:4.0.0-slim AS build

RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    build-essential git libyaml-dev pkg-config && rm -rf /var/lib/apt/lists/*
WORKDIR /app
ENV BUNDLE_DEPLOYMENT=1 BUNDLE_PATH=/usr/local/bundle
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 4.0.24 --no-document && bundle install --jobs 4 --retry 3 \
    && rm -rf /usr/local/bundle/cache

FROM ruby:4.0.0-slim
RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    libyaml-0-2 git && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 1000 app && useradd --uid 1000 --gid app --create-home app
WORKDIR /app
ENV BUNDLE_DEPLOYMENT=1 BUNDLE_PATH=/usr/local/bundle
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --chown=app:app . .
RUN mkdir -p tmp/pids log && chown -R app:app tmp log
USER app
EXPOSE 3000
ENTRYPOINT ["/app/bin/docker-entrypoint"]
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
