# frozen_string_literal: true

require 'capybara'
require 'capybara/rspec'
require 'rspec'

require_relative '../src/dependabot-nano-api/config'
require_relative '../src/dependabot-nano-api/server'

Capybara.app = Cuba

RSpec.configure do |config|
  config.include Capybara::DSL
  config.include Capybara::RSpecMatchers
end
