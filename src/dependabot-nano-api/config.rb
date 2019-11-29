# frozen_string_literal: true

require 'dependabot/omnibus'

module DependabotNanoApi
  ## Configuration utilities.
  module Config
    DEFAULT = {
      gitlab_host: 'gitlab.com',
      pypi_base_url: 'https://pypi.org/index'
    }

    def self.from_env(env)
      {
        gitlab_host: env['GITLAB_HOST'] || DEFAULT[:gitlab_host],
        pypi_base_url: env['PYPI_BASE_URL'] || DEFAULT[:pypi_base_url],
      }
    end

    def self.apply!(config)
      Dependabot::Python::UpdateChecker::IndexFinder.const_set(
        'PYPI_BASE_URL', config[:pypi_base_url]
      )
    end
  end
end
