# frozen_string_literal: true

require 'cuba'
require 'cuba/safe'

require_relative '../dependabot-nano-api'
require_relative '../dependabot-nano-api/config'
require_relative '../dependabot-nano-api/runner'

Cuba.plugin Cuba::Safe

Cuba.define do
  on get do
    on 'gitlab', param('repo'), param('token'), param('manager') do |repo, token, manager|
      config = DependabotNanoApi::Config.from_env(ENV)
      DependabotNanoApi::Runner.run!(config, repo, token, manager)
    end

    on 'version' do
      res.write DependabotNanoApi::VERSION
    end
  end
end
