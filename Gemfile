# frozen_string_literal: true

source "https://rubygems.org", cooldown: 7

# Specify your gem's dependencies in rbs_discard.gemspec
gemspec

gem "rake", "~> 13.4"

gem "rubocop", "~> 1.88"
gem "rubocop-rake"
gem "rubocop-rbs_inline"
gem "rubocop-rspec"

group :development do
  gem "rbs-inline", require: false
  gem "rspec", require: false
  gem "rspec-daemon", require: false
  gem "steep", require: false
end
