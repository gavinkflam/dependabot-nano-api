# frozen_string_literal: true

require 'spec_helper'

describe 'API server' do
  it 'tells the version' do
    visit '/version'
    expect(page).to have_content DependabotNanoApi::VERSION
  end
end
