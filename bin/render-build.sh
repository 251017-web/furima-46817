#!/usr/bin/env bash
set -o errexit

export RAILS_ENV="${RAILS_ENV:-production}"

bundle install
bundle exec rails assets:precompile
bundle exec rails db:migrate
