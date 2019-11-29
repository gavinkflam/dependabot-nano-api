# frozen_string_literal: true

require 'cuba'
require 'cuba/safe'

require_relative '../dependabot-nano-api'

Cuba.plugin Cuba::Safe

Cuba.define do
  on get do
    on 'gitlab', param('project'), param('token') do |project, token|
      res.write "#{project} - #{token}"
    end

    on 'version' do
      res.write DependabotNanoApi::VERSION
    end
  end
end
