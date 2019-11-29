# frozen_string_literal: true

require 'dependabot/omnibus'

module DependabotNanoApi
  ## Configuration utilities.
  module Config
    DEFAULT = {
      gitlab_host: 'gitlab.com',
      pip_index_url: 'https://pypi.org/index'
    }

    def self.from_env(env)
      {
        gitlab_host: env['GITLAB_HOST'] || DEFAULT[:gitlab_host],
        pip_index_url: env['PIP_INDEX_URL'] || DEFAULT[:pip_index_url],
      }
    end

    def self.apply!(config)
      Dependabot::Python::UpdateChecker::IndexFinder.const_set(
        'PYPI_BASE_URL', config[:pip_index_url]
      )
    end
  end
end
