# frozen_string_literal: true

require 'spec_helper'

describe 'Config' do
  it 'derives config from environment variables' do
    env = {
      'GITLAB_HOST' => 'gitlab.example.com',
      'PYPI_BASE_URL' => 'https://pypi.example.com/simple/'
    }
    config = DependabotNanoApi::Config.from_env(env)

    expect(config[:gitlab_host]).to be('gitlab.example.com')
    expect(config[:pypi_base_url]).to be('https://pypi.example.com/simple/')
  end

  it 'applies config' do
    expect(
      Dependabot::Python::UpdateChecker::IndexFinder::PYPI_BASE_URL
    ).to be('https://pypi.python.org/simple/')

    config = {
      pypi_base_url: 'https://pypi.example.com/simple/'
    }
    DependabotNanoApi::Config.apply!(config)

    expect(
      Dependabot::Python::UpdateChecker::IndexFinder::PYPI_BASE_URL
    ).to be('https://pypi.example.com/simple/')
  end
end
